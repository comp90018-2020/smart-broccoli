import 'package:flutter/widgets.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:smart_broccoli/router.dart';
import 'package:smart_broccoli/src/base.dart';
import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/remote.dart';

enum SessionState {
  PENDING, // in lobby and waiting (unknown how long to start)
  STARTING, // the quiz will start in a known number of seconds
  QUESTION,
  ANSWER,
  OUTCOME,
  FINISHED,
  ABORTED,
  ABANDONED,
}

class GameSessionModel extends ChangeNotifier implements AuthChange {
  // URL of server
  static const String SERVER_URL = 'https://fuzzybroccoli.com';

  /// AuthStateModel object used to obtain token for requests
  final AuthStateModel _authStateModel;

  /// QuizCollectionModel used to obtain pictures and refresh quizzes
  final QuizCollectionModel _quizCollectionModel;

  /// UserRepository used to obtain participant avatars
  final UserRepository _userRepo;

  /// API provider for the session API (non-websocket)
  SessionApi _sessionApi;

  /// The current session in which the user is participating
  GameSession session;

  /// All players currently in the session
  Map<int, SocketUser> players = {};

  /// The user role (host = GroupRole.OWNER, participant = GroupRole.MEMBER)
  GroupRole role;

  /// Total number of questions in the quiz
  int totalQuestions;

  /// Current state of the session (determines navigation)
  SessionState state;

  ////// Lobby //////

  /// Countdown (when known) for lobby to first question
  int startCountDown;

  /// Hint text shown while user is in the lobby
  String get waitHint {
    if (session.quizType == QuizType.SELF_PACED)
      return 'Waiting for quiz to start...';

    if (state == SessionState.PENDING)
      return role == GroupRole.MEMBER
          ? 'Waiting for host to start...'
          : 'Invite others by PIN: ' + session.joinCode;

    if (state == SessionState.STARTING) return 'Quiz starting!';

    return null;
  }

  ////// Question //////

  /// The current question of the session
  Question question;

  /// Hint text shown while user is on a question
  String get questionHint {
    if (question is TFQuestion || (question as MCQuestion).numCorrect == 1)
      return role == GroupRole.MEMBER ? 'Select an answer' : null;
    return role == GroupRole.MEMBER
        ? 'Select ${(question as MCQuestion).numCorrect} answers'
        : '${(question as MCQuestion).numCorrect} correct answers';
  }

  /// Allocated time for the current question
  int time;

  /// The user's submitted answer
  Answer answer;

  /// Record of how many people have answered the current question (unused)
  QuestionAnswered questionAnswered;

  ////// Answer //////

  /// Leaderboard (all users) and record (participants only)
  Outcome outcome;

  /// The correct answer(s) to the question
  CorrectAnswer correctAnswer;

  /// The most up-to-date value of the user's points (where available)
  int get points =>
      correctAnswer?.record?.points ?? (outcome as OutcomeUser)?.record?.points;

  /// The socket which we enclose
  IO.Socket socket;

  GameSessionModel(
      this._authStateModel, this._quizCollectionModel, this._userRepo,
      {SessionApi sessionApi}) {
    _sessionApi = sessionApi ?? SessionApi();
    socket = IO.io(SERVER_URL, {
      'autoConnect': false,
      'transports': ['websocket']
    });
  }

  /// Get current user's session (may be null -> user not in session)
  Future<void> refreshSession() async {
    if (!_authStateModel.inSession) return;

    try {
      if ((session = await _sessionApi.getSession(_authStateModel.token)) !=
          null) {
        socket.disconnect();
        _connect(session.token);
      }
    } on ApiAuthException {
      _authStateModel.checkSession();
    } on ApiException catch (e) {
      return Future.error(e.toString());
    } on Exception {
      return Future.error("Something went wrong");
    }
  }

  /// Create session (supporting multiple creation types)
  Future<void> createSession(int quizId, GameSessionType type,
      {bool autoSubscribe = false}) async {
    try {
      session = await _sessionApi.createSession(
          _authStateModel.token, quizId, type,
          autoSubscribe: autoSubscribe);
      _connect(session.token);
    } on ApiAuthException {
      _authStateModel.checkSession();
    } on ApiException catch (e) {
      return Future.error("Cannot start session: ${e.toString()}");
    } on Exception {
      return Future.error("Something went wrong");
    }
  }

  List<GameSession> getGroupSessions(Quiz quiz) => quiz.sessions
      .where((session) =>
          session.quizType == QuizType.SELF_PACED &&
          session.type == GameSessionType.GROUP &&
          session.state != GameSessionState.ENDED &&
          session.joinCode != null)
      .toList();

  Color getSessionColour(GameSession session) =>
      Color(int.parse('FF${session.joinCode}', radix: 16));

  Future<void> joinSessionByPin(String pin) async {
    try {
      session = await _sessionApi.joinSession(_authStateModel.token, pin);
      _connect(session.token);
      notifyListeners();
    } on ApiAuthException {
      _authStateModel.checkSession();
    } on SessionNotFoundException catch (e) {
      return Future.error(e);
    } on ApiException catch (e) {
      return Future.error(e.toString());
    } on Exception {
      return Future.error("Something went wrong");
    }
  }

  Future<void> _joinSession(GameSession quizSession) async {
    session = await _sessionApi.joinSession(
        _authStateModel.token, quizSession.joinCode);
    _connect(session.token);
    notifyListeners();
  }

  Future<void> joinLiveSession(Quiz quiz) async {
    try {
      await _joinSession(quiz.sessions.firstWhere((session) =>
          session.quizType == QuizType.LIVE &&
          session.state != GameSessionState.ENDED));
    } on ApiAuthException {
      _authStateModel.checkSession();
    } on SessionNotFoundException {
      _quizCollectionModel
          .getQuiz(quiz.id, refresh: true)
          .catchError((_) => null);
      return Future.error("Session no longer exists, refreshing...");
    } on ApiException catch (e) {
      return Future.error(e.toString());
    } on Exception {
      return Future.error("Something went wrong");
    }
  }

  /// Get path of peer's profile picture, where path is cached local path
  /// Should be called from a FutureBuilder
  Future<String> getPeerProfilePicturePath(int userId) async {
    String path;
    // check if cached
    if ((path = await _userRepo.getUserPicture(userId)) != null) return path;

    // if not, retrieve from server
    try {
      await _userRepo.getUserBy(session.token, userId);
    } on ApiAuthException {
      _authStateModel.checkSession();
    } on ApiException catch (e) {
      return Future.error(e.toString());
    } on Exception {
      return Future.error("Something went wrong");
    }
    return _userRepo.getUserPicture(userId);
  }

  /// Establish a websocket connection with the gameplay server.
  ///
  /// This method also routes the user to the appropriate initial screen via
  /// PubSub() event.
  void _connect(String token) {
    // clear previous session data
    _clearFields();

    // Set query
    socket.opts['query'] = {};
    socket.opts['query']['token'] = token;
    socket.connect();

    socket.on('connect', (message) {
      notifyListeners();
    });

    socket.on('welcome', (message) {
      List users = message['players'] as List;
      players = Map.fromIterable(users.map((u) => SocketUser.fromJson(u)),
          key: (u) => u.id);
      if ('participant' == message['role'])
        role = GroupRole.MEMBER;
      else
        role = GroupRole.OWNER;

      switch (message['status']) {
        case 'pending':
          _transitionTo(SessionState.PENDING);
          break;
        case 'starting':
          _transitionTo(SessionState.STARTING);
          break;
        case 'running':
          _transitionTo(SessionState.QUESTION);
          break;
        default:
          _transitionTo(SessionState.ABORTED);
      }
    });

    socket.on('playerJoin', (message) {
      var user = SocketUser.fromJson(message);
      players[user.id] = user;
      notifyListeners();
    });

    socket.on('playerLeave', (message) {
      var user = SocketUser.fromJson(message);
      players.remove(user.id);
      notifyListeners();
    });

    socket.on('starting', (message) {
      startCountDown = int.parse(message);
      _transitionTo(SessionState.STARTING);
    });

    socket.on('cancelled', (message) {
      _transitionTo(SessionState.ABORTED);
      socket.disconnect();
    });

    socket.on('nextQuestion', (message) async {
      if (message['question']['options'] == null)
        question = TFQuestion.fromJson(message['question']);
      else
        question = MCQuestion.fromJson(message['question']);
      time = message['time'];
      totalQuestions = message['totalQuestions'];

      // empty answer object for this question
      answer = Answer(question.no);
      try {
        await _quizCollectionModel.refreshQuestionPicture(
            session.quizId, question,
            token: session.token);
      } on ApiAuthException {
        _authStateModel.checkSession();
      } catch (_) {
        // Do nothing, picture is not loaded
      }
      _transitionTo(SessionState.QUESTION);
      PubSub().publish(PubSubTopic.TIMER, arg: time);
    });

    socket.on('questionAnswered', (message) {
      // TODO: future enhancement
    });

    socket.on('correctAnswer', (message) {
      correctAnswer = CorrectAnswer.fromJson(message);
      _transitionTo(SessionState.ANSWER);
    });

    socket.on('questionOutcome', (message) {
      if (role == GroupRole.OWNER)
        outcome = Outcome.fromJson(message);
      else
        outcome = OutcomeUser.fromJson(message);
      _transitionTo(SessionState.OUTCOME);
    });

    socket.on('end', (_) {
      _transitionTo(SessionState.FINISHED);
    });

    socket.on('disconnect', (_) {
      // must stop listening immediately to avoid timing conflicts
      socket.clearListeners();

      if (state == SessionState.ABORTED)
        PubSub().publish(PubSubTopic.ROUTE,
            arg: RouteArgs(action: RouteAction.DIALOG_POPALL_SESSION));
      else if (state == SessionState.ABANDONED)
        PubSub().publish(PubSubTopic.ROUTE,
            arg: RouteArgs(action: RouteAction.POPALL_SESSION));
    });
  }

  /// State transition upon receiving event.
  void _transitionTo(SessionState updated) {
    switch (updated) {
      case SessionState.PENDING:
        state = SessionState.PENDING;
        PubSub().publish(PubSubTopic.ROUTE,
            arg: RouteArgs(name: '/session/lobby', action: RouteAction.PUSH));
        break;
      case SessionState.STARTING:
        if (state == SessionState.PENDING)
          notifyListeners();
        else
          PubSub().publish(PubSubTopic.ROUTE,
              arg: RouteArgs(name: '/session/lobby', action: RouteAction.PUSH));
        PubSub().publish(PubSubTopic.TIMER, arg: startCountDown);
        state = SessionState.STARTING;
        break;
      case SessionState.QUESTION:
        if (state == SessionState.PENDING || state == SessionState.STARTING) {
          PubSub().publish(PubSubTopic.ROUTE,
              arg: RouteArgs(
                  name: '/session/question', action: RouteAction.REPLACE));
          PubSub().publish(PubSubTopic.TIMER, arg: time);
        } else if (state == SessionState.QUESTION ||
            state == SessionState.ANSWER)
          notifyListeners();
        else if (state == SessionState.OUTCOME) {
          PubSub().publish(PubSubTopic.ROUTE,
              arg: RouteArgs(action: RouteAction.POP_LEADERBOARD));
          PubSub().publish(PubSubTopic.TIMER, arg: time);
          notifyListeners();
        } else {
          PubSub().publish(PubSubTopic.ROUTE,
              arg: RouteArgs(
                  name: '/session/question', action: RouteAction.PUSH));
          PubSub().publish(PubSubTopic.TIMER, arg: time);
        }
        state = SessionState.QUESTION;
        break;
      case SessionState.ANSWER:
        if (state == SessionState.QUESTION)
          notifyListeners();
        else
          PubSub().publish(PubSubTopic.ROUTE,
              arg: RouteArgs(
                  name: '/session/question', action: RouteAction.PUSH));
        state = SessionState.ANSWER;
        break;
      case SessionState.OUTCOME:
        notifyListeners();
        PubSub().publish(PubSubTopic.ROUTE,
            arg: RouteArgs(
                name: '/session/leaderboard', action: RouteAction.PUSH));
        state = SessionState.OUTCOME;
        break;
      case SessionState.FINISHED:
        notifyListeners();
        state = SessionState.FINISHED;
        break;
      case SessionState.ABORTED:
        state = SessionState.ABORTED;
        break;
      case SessionState.ABANDONED:
        state = SessionState.ABANDONED;
        break;
    }
  }

  /// host action
  void startQuiz() {
    socket.emit('start');
  }

  void abortQuiz() {
    socket.emit('abort');
    // for host, transition to ABANDONED to avoid getting dialogue box
    _transitionTo(SessionState.ABANDONED);
  }

  /// Select an answer.
  ///
  /// No deselection behaviour is enabled. This method should be called by
  /// the class controlling the pinball.
  void selectAnswer(int index) {
    if (role == GroupRole.OWNER) return;

    if (question is TFQuestion) {
      // repeat selection: no need to resend
      if (answer.tfSelection != null &&
          (answer.tfSelection && index == 1 ||
              !answer.tfSelection && index == 0)) return;
      // first selection or change of selection
      answer.tfSelection = index == 0 ? false : true;
      answerQuestion();
      notifyListeners();
    }

    // MC question with only one correct answer
    else if ((question as MCQuestion).numCorrect == 1) {
      // repeat tap: no need to resend
      if (answer.mcSelection.contains(index)) return;
      // first selection or change of selection
      answer.mcSelection
        ..clear()
        ..add(index);
      answerQuestion();
      notifyListeners();
    }

    // MCQ with no. selections < no. correct and answer not already selected
    else if (answer.mcSelection.length < (question as MCQuestion).numCorrect &&
        !answer.mcSelection.contains(index)) {
      answer.mcSelection.add(index);
      notifyListeners();
      // send answer if no. selections == no. correct
      if (answer.mcSelection.length == (question as MCQuestion).numCorrect)
        answerQuestion();
    }
  }

  /// Toggle an answer.
  ///
  /// Deselection behaviour is enabled for MC questions with multiple correct
  /// answers. The class controlling the pinball should not call this method.
  /// This is only be invoked by a user performing a button tap.
  void toggleAnswer(int index) {
    if (role == GroupRole.OWNER) return;

    // TF question: only one answer can be selected
    if (question is TFQuestion) {
      // repeat tap: no need to resend
      if (answer.tfSelection != null &&
          (answer.tfSelection && index == 1 ||
              !answer.tfSelection && index == 0)) return;
      // first selection or change of selection
      answer.tfSelection = index == 0 ? false : true;
      answerQuestion();
      notifyListeners();
    }

    // MC question with only one correct answer
    else if ((question as MCQuestion).numCorrect == 1) {
      // repeat tap: no need to resend
      if (answer.mcSelection.contains(index)) return;
      // first selection or change of selection
      answer.mcSelection
        ..clear()
        ..add(index);
      answerQuestion();
      notifyListeners();
    }

    // MC question with multiple answers
    else {
      // deselection
      if (answer.mcSelection.contains(index)) {
        answer.mcSelection.remove(index);
        notifyListeners();
      }

      // selection as long as no. selections does not exceed no. correct
      else if (answer.mcSelection.length <
          (question as MCQuestion).numCorrect) {
        answer.mcSelection.add(index);
        notifyListeners();
        // send answer if no. selections == no. correct
        if (answer.mcSelection.length == (question as MCQuestion).numCorrect)
          answerQuestion();
      }
    }
  }

  void nextQuestion() {
    socket.emit('next');
  }

  void showLeaderBoard() {
    socket.emit('showBoard');
  }

  /// participant action
  void quitQuiz() {
    if (role == GroupRole.MEMBER) {
      // must handle finished state separately as connection is closed
      if (state == SessionState.FINISHED) {
        PubSub().publish(PubSubTopic.ROUTE,
            arg: RouteArgs(action: RouteAction.POPALL_SESSION));
      }
      _transitionTo(SessionState.ABANDONED);
      socket.emit('quit');
    } else
      // quiz owner
      abortQuiz();
    socket.disconnect();
  }

  void answerQuestion() {
    socket.emit('answer', answer.toJson());
  }

  void _clearFields() {
    players.clear();
    startCountDown = null;
    question = null;
    time = null;
    totalQuestions = null;
    outcome = null;
    questionAnswered = null;
    correctAnswer = null;
    role = null;
    answer = null;
    state = null;
    socket.disconnect();
  }

  @override
  void authUpdated() {
    if (!_authStateModel.inSession) _clearFields();
  }
}

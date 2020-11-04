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

  final QuizCollectionModel _quizCollectionModel;

  final UserRepository _userRepo;

  SessionApi _sessionApi;

  GameSession session;
  Map<int, SocketUser> players = {};
  int startCountDown;
  Question question;
  int time;
  int totalQuestion;
  Outcome outcome;
  QuestionAnswered questionAnswered;
  CorrectAnswer correctAnswer;
  GroupRole role;
  Answer answer;
  SessionState state;

  String get waitHint {
    if (session.quizType == QuizType.SELF_PACED)
      return 'Waiting for quiz to start...';

    if (state == SessionState.PENDING)
      return role == GroupRole.MEMBER
          ? 'Waiting for host to start...'
          : 'Tap to start for everyone';

    if (state == SessionState.STARTING) return 'Quiz starting!';

    return null;
  }

  String get questionHint {
    if (question is TFQuestion || (question as MCQuestion).numCorrect == 1)
      return role == GroupRole.MEMBER ? 'Select an answer' : null;
    return role == GroupRole.MEMBER
        ? 'Select ${(question as MCQuestion).numCorrect} answers'
        : '${(question as MCQuestion).numCorrect} correct answers';
  }

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

  Future<void> refreshSession() async {
    if (!_authStateModel.inSession) return;
    if ((session = await _sessionApi.getSession(_authStateModel.token)) !=
        null) {
      socket.disconnect();
      _connect(session.token);
    }
  }

  Future<void> createSession(int quizId, GameSessionType type,
      {bool autoSubscribe = false}) async {
    session = await _sessionApi.createSession(
        _authStateModel.token, quizId, type,
        autoSubscribe: autoSubscribe);
    _connect(session.token);
  }

  Future<void> joinSession(GameSession quizSession) async {
    session = await _sessionApi.joinSession(
        _authStateModel.token, quizSession.joinCode);
    _connect(session.token);
    notifyListeners();
  }

  Future<void> joinLiveSession(Quiz quiz) async {
    await joinSession(quiz.sessions.firstWhere((session) =>
        session.quizType == QuizType.LIVE &&
        session.state != GameSessionState.ENDED));
  }

  Future<String> getPeerProfilePicturePath(int userId) async {
    String path;
    // check if cached
    if ((path = await _userRepo.getUserPicture(userId)) != null) return path;
    // if not, retrieve from server
    await _userRepo.getUserBy(session.token, userId);
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
      totalQuestion = message['totalQuestions'];

      // empty answer object for this question
      answer = Answer(question.no);
      try {
        await _quizCollectionModel.refreshQuestionPicture(
            session.quizId, question,
            token: session.token);
      } catch (_) {}
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

      // refresh quiz information before user navigates back to take quiz pages
      if (role == GroupRole.MEMBER)
        _quizCollectionModel.refreshAvailableQuizzes();
      else
        _quizCollectionModel.refreshCreatedQuizzes();

      if (state == SessionState.ABORTED) {
        PubSub().publish(PubSubTopic.ROUTE,
            arg: RouteArgs(action: RouteAction.DIALOG_POPALL_SESSION));
        _clearFields();
      } else if (state == SessionState.ABANDONED) {
        PubSub().publish(PubSubTopic.ROUTE,
            arg: RouteArgs(action: RouteAction.POPALL_SESSION));
        _clearFields();
      }
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
    socket.disconnect();
  }

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
        _clearFields();
      }
      _transitionTo(SessionState.ABANDONED);
      socket.emit('quit');
    } else
      // quiz owner
      abortQuiz();
  }

  void answerQuestion() {
    socket.emit('answer', answer.toJson());
  }

  void _clearFields() {
    players.clear();
    startCountDown = null;
    question = null;
    time = null;
    totalQuestion = null;
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

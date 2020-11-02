import 'package:flutter/widgets.dart';
import 'package:smart_broccoli/router.dart';
import 'package:smart_broccoli/src/base.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models/auth_state.dart';
import 'package:smart_broccoli/src/models/model_change.dart';
import 'package:smart_broccoli/src/remote.dart';

enum SessionState {
  PENDING, // in lobby and waiting (unknown how long to start)
  STARTING, // the quiz will start in a known number of seconds
  QUESTION,
  ANSWER,
  OUTCOME,
  FINISHED,
  ABORTED,
}

class GameSessionModel extends ChangeNotifier implements AuthChange {
  // URL of server
  static const String SERVER_URL = 'https://fuzzybroccoli.com';

  /// AuthStateModel object used to obtain token for requests
  final AuthStateModel _authStateModel;

  final PubSub pubSub;

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
          : 'Tap \'start\' to begin';

    if (state == SessionState.STARTING) return 'Quiz starting!';

    return null;
  }

  /// The socket which we enclose
  IO.Socket socket;

  GameSessionModel(this._authStateModel, this.pubSub, {SessionApi sessionApi}) {
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
    await joinSession(quiz.sessions
        .firstWhere((session) => session.quizType == QuizType.LIVE));
  }

  /// Establish a websocket connection with the gameplay server.
  ///
  /// This method also routes the user to the appropriate initial screen via
  /// pubsub event.
  void _connect(String token) {
    // Set query
    socket.opts['query'] = {};
    socket.opts['query']['token'] = token;
    print(socket.opts);
    socket.connect();

    socket.on('connect', (message) {
      print('connected');
      notifyListeners();
    });

    socket.on('welcome', (message) {
      print('welcome');
      print(message);
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

      print(players);
      print(role);
      print(state);
    });

    socket.on('playerJoin', (message) {
      print(message);
      var user = SocketUser.fromJson(message);
      players[user.id] = user;
      print("playerJoin");
      print(players);
      notifyListeners();
    });

    socket.on('playerLeave', (message) {
      print("playerLeave");
      print(message);
      var user = SocketUser.fromJson(message);
      players.remove(user.id);
      print(players);
      notifyListeners();
    });

    socket.on('starting', (message) {
      print("starting");
      print(message);
      startCountDown = int.parse(message);
      print(startCountDown);
      _transitionTo(SessionState.STARTING);
    });

    socket.on('cancelled', (message) {
      print("cancelled");
      socket.disconnect();
      _transitionTo(SessionState.ABORTED);
    });

    socket.on('nextQuestion', (message) {
      print("nextQuestion");
      print(message);
      if (message['question']['options'] == null)
        question = TFQuestion.fromJson(message['question']);
      else
        question = MCQuestion.fromJson(message['question']);
      time = message['time'];
      totalQuestion = message['totalQuestions'];

      print(question);
      print(time);
      print(totalQuestion);
      _transitionTo(SessionState.QUESTION);
    });

    socket.on('questionAnswered', (message) {
      // TODO: future enhancement
    });

    socket.on('correctAnswer', (message) {
      print("correctAnswer");
      print(message);
      correctAnswer = CorrectAnswer.fromJson(message);
      print(correctAnswer);
      _transitionTo(SessionState.ANSWER);
    });

    socket.on('questionOutcome', (message) {
      print("questionOutcome: ");
      print(message);
      print(role);
      if (role == GroupRole.OWNER) {
        outcome = Outcome.fromJson(message);
        print(outcome);
      } else {
        outcome = OutcomeUser.fromJson(message);
        print(outcome);
      }
      _transitionTo(SessionState.OUTCOME);
    });

    socket.on('end', (_) {
      print('end');
      _transitionTo(SessionState.FINISHED);
    });

    socket.on('disconnect', (_) {
      // must stop listening immediately to avoid timing conflicts
      socket.clearListeners();
      _clearFields();
      pubSub.publish(PubSubTopic.ROUTE,
          arg: RouteArgs(name: '/take_quiz', action: RouteAction.POPALL));
    });
  }

  /// State transition upon receiving event.
  void _transitionTo(SessionState updated) {
    switch (updated) {
      case SessionState.PENDING:
        state = SessionState.PENDING;
        pubSub.publish(PubSubTopic.ROUTE,
            arg: RouteArgs(name: '/session/lobby', action: RouteAction.PUSH));
        break;
      case SessionState.STARTING:
        if (state == SessionState.PENDING)
          notifyListeners();
        else
          pubSub.publish(PubSubTopic.ROUTE,
              arg: RouteArgs(name: '/session/lobby', action: RouteAction.PUSH));
        state = SessionState.STARTING;
        break;
      case SessionState.QUESTION:
        if (state == SessionState.PENDING || state == SessionState.STARTING)
          pubSub.publish(PubSubTopic.ROUTE,
              arg: RouteArgs(
                  name: '/session/question', action: RouteAction.REPLACE));
        else if (state == SessionState.QUESTION || state == SessionState.ANSWER)
          notifyListeners();
        else if (state == SessionState.OUTCOME)
          pubSub.publish(PubSubTopic.ROUTE,
              arg: RouteArgs(action: RouteAction.POP));
        else
          pubSub.publish(PubSubTopic.ROUTE,
              arg: RouteArgs(
                  name: '/session/question', action: RouteAction.PUSH));
        state = SessionState.QUESTION;
        break;
      case SessionState.ANSWER:
        if (state == SessionState.QUESTION) {
          print('QUESTION TO ANSWER TRANSITION');
          notifyListeners();
        } else
          pubSub.publish(PubSubTopic.ROUTE,
              arg: RouteArgs(
                  name: '/session/question', action: RouteAction.PUSH));
        state = SessionState.ANSWER;
        break;
      case SessionState.OUTCOME:
        pubSub.publish(PubSubTopic.ROUTE,
            arg: RouteArgs(
                name: '/session/leaderboard', action: RouteAction.PUSH));
        state = SessionState.OUTCOME;
        break;
      case SessionState.FINISHED:
        if (state == SessionState.ANSWER)
          pubSub.publish(PubSubTopic.ROUTE,
              arg:
                  RouteArgs(name: '/session/finish', action: RouteAction.PUSH));
        else
          notifyListeners();
        state = SessionState.FINISHED;
        break;
      case SessionState.ABORTED:
        pubSub.publish(PubSubTopic.ROUTE,
            arg: RouteArgs(action: RouteAction.DIALOG_POPALL_SESSION));
        state = SessionState.ABORTED;
        break;
    }
  }

  /// host action
  void startQuiz() {
    socket.emit('start');
  }

  void abortQuiz() {
    socket.emit('abort');
    socket.disconnect();
  }

  void nextQuestion() {
    socket.emit('next');
  }

  void showLeaderBoard() {
    socket.emit('showBoard');
  }

  /// participant action
  void quitQuiz() {
    socket.emit('quit');
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

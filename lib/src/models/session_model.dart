import 'package:flutter/widgets.dart';
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

  /// The socket which we enclose
  IO.Socket socket;

  GameSessionModel(this._authStateModel, {SessionApi sessionApi}) {
    _sessionApi = sessionApi ?? SessionApi();
    socket = IO.io(SERVER_URL, {
      'autoConnect': false,
      'transports': ['websocket']
    });
  }

  Future<void> refreshSession() async {
    GameSession current = await _sessionApi.getSession(_authStateModel.token);
    if (session == null && current == null) return;
    session = current;
    notifyListeners();
  }

  Future<void> createSession(Quiz quiz, GameSessionType type,
      {bool autoSubscribe = false}) async {
    session = await _sessionApi.createSession(
        _authStateModel.token, quiz.id, type,
        autoSubscribe: autoSubscribe);
    notifyListeners();
  }

  Future<void> joinSession(GameSession session) async {
    session =
        await _sessionApi.joinSession(_authStateModel.token, session.joinCode);
    notifyListeners();
  }

  Future<void> joinLiveSession(Quiz quiz) async {
    joinSession(quiz.sessions
        .firstWhere((session) => session.quizType == QuizType.LIVE));
  }

  /// Connect to socket with headers
  void connect(String token) {
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

      //need to check
      if ('pending' == message['status'])
        state = SessionState.PENDING;
      else if ('starting' == message['status'])
        state = SessionState.STARTING;
      else if ('running' == message['status'])
        state = SessionState.QUESTION;
      else
        state = SessionState.ABORTED;

      print(players);
      print(role);
      print(state);
      notifyListeners();
    });

    socket.on('playerJoin', (message) {
      print(message);
      var user = SocketUser.fromJson(message);
      players[user.id] = user;
      print("playerJoin");
      print(players);
    });

    socket.on('playerLeave', (message) {
      print("playerLeave");
      print(message);
      var user = SocketUser.fromJson(message);
      players.remove(user.id);
      print(players);
    });

    socket.on('starting', (message) {
      print("starting");
      print(message);
      startCountDown = int.parse(message);
      print(startCountDown);
      state = SessionState.STARTING;
      notifyListeners();
    });

    socket.on('cancelled', (message) {
      print("cancelled");
      socket.disconnect();
      state = SessionState.ABORTED;
      notifyListeners();
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

      state = SessionState.QUESTION;
      notifyListeners();
    });

    socket.on('questionAnswered', (message) {
      print("questionAnswered");
      print(message);
      questionAnswered = QuestionAnswered.fromJson(message);
      print(questionAnswered);
      state = SessionState.QUESTION;
      notifyListeners();
    });

    socket.on('correctAnswer', (message) {
      print("correctAnswer");
      print(message);
      correctAnswer = CorrectAnswer.fromJson(message);
      print(correctAnswer);
      state = SessionState.ANSWER;
      notifyListeners();
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
      state = SessionState.OUTCOME;
      notifyListeners();
    });

    socket.on('end', (_) {
      print('end');
      state = SessionState.FINISHED;
    });

    socket.on('disconnect', (message) {
      socket.clearListeners();
    });
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
    socket.disconnect();
  }

  void answerQuestion() {
    socket.emit('answer', answer.toJson());
  }

  @override
  void authUpdated() {
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
    socket = null;
  }
}

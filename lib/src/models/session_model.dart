import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/socket_data/correct_answer.dart';
import 'package:smart_broccoli/src/socket_data/question_answered.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../socket_data/user.dart' as SocketUser;
import '../socket_data/outcome.dart';
import '../data/group.dart';
import 'package:flutter/widgets.dart';

enum SessionState {
  PENDING, // in lobby and waiting (unknown how long to start)
  STARTING, // the quiz will start in a known number of seconds
  QUESTION,
  ANSWER,
  OUTCOME,
  FINISHED,
  ABORTED,
}

void main() {
  GameSessionModel test = new GameSessionModel();
  test.connect(2, 1);
  // test.startQuiz();
}

class GameSessionModel extends ChangeNotifier{
  // URL of server
  static const String SERVER_URL = 'https://fuzzybroccoli.com';

  Map<int, SocketUser.User> players = {};
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

  GameSessionModel() {
    socket = IO.io(SERVER_URL, {
      'autoConnect': false,
      'transports': ['websocket']
    });
  }

  /// Connect to socket with headers
  /// TODO: change to token
  void connect(int userId, int sessionId) {
    //change to token
    // Set query
    socket.opts['query'] = {};
    socket.opts['query']['userId'] = userId;
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
      players = Map.fromIterable(users.map((u) => SocketUser.User.fromJson(u)),
          key: (u) => u.id);
      role = message['role'];

      //need to check
      if ('pending' == message['state'])
        state = SessionState.PENDING;
      else if ('starting' == message['state'])
        state = SessionState.STARTING;
      else if ('running' == message['state'])
        state = SessionState.QUESTION;
      else if ('ended' == message['state'])
        state = SessionState.OUTCOME;
      else
        state = SessionState.ABORTED;

      print(players);
      print(role);
      print(state);
      notifyListeners();
    });

    socket.on('playerJoin', (message) {
      print(message);
      var user = SocketUser.User.fromJson(message);
      players[user.id] = user;
      print("playerJoin");
      print(players);
    });

    socket.on('playerLeave', (message) {
      print("playerLeave");
      print(message);
      var user = SocketUser.User.fromJson(message);
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
      // socket.disconnected;
      print("cancelled");
      socket.disconnect();
      state = SessionState.ABORTED;
      notifyListeners();
    });

    socket.on('nextQuestion', (message) {
      print("nextQuestion");
      print(message);
      if(message['question']['options'] == null)
        question = TFQuestion.fromJson(message['question']);
      else
        question = MCQuestion.fromJson(message['question']);
      time = message['time'];
      totalQuestion = message['totalQuestion'];

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
      print("questionAnswered");
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

  // /// Subscribe to socket event
  // void _subscribe(String event, dynamic Function(dynamic) handler) {
  //   if (socket.disconnected) {
  //     throw new Exception("Socket is not connected");
  //   }
  //   print('$event has been called');
  //   socket.on(event, handler);
  // }
  //
  // /// Emit data to socket
  // void _emit(String event, [dynamic data]) {
  //   if (socket.disconnected) {
  //     throw new Exception("Socket is not connected");
  //   }
  //   socket.emit(data);
  // }
  //
  // /// Close and dispose all event listeners
  // void _disconnect() {
  //   socket.disconnect();
  // }

  /// get data from socket
// String receive_from_socket(String event, dynamic data){
// //
// // }
// //
// // void send_to_socket(String event, dynamic data){
// //
// // }
}

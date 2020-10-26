import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/socket_data/question_answered.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../socket_data/user.dart' as SocketUser;
import '../socket_data/question.dart' as questionType;
import '../socket_data/outcome.dart';
import '../data/group.dart';

enum SessionState {
  PENDING, // in lobby and waiting (unknown how long to start)
  STARTING, // the quiz will start in a known number of seconds
  QUESTION, // the quiz is currently on a question
  OUTCOME, // between questions (LeaderBoard)
  FINISHED,
  ABORTED,
}

void main() {
  GameSessionModel test = new GameSessionModel();
  test.connect(2, 1);
  // test.startQuiz();
}

class GameSessionModel {
  // URL of server
  static const String SERVER_URL = 'https://fuzzybroccoli.com';

  Map<int, SocketUser.User> players = {};
  int startCountDown;
  questionType.Question question;
  Outcome outcome;
  // List<int> questionAnswered = [];
  QuestionAnswered questionAnswered;
  GroupRole userRole;
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
      // notifyListeners();
    });

    socket.on('welcome', (message) {
      print('welcome');
      print(message);
      List users = message as List;
      players = Map.fromIterable(users.map((u) => SocketUser.User.fromJson(u)),
          key: (u) => u.id);
      print(players);
      state = SessionState.PENDING;
      // notifyListeners();
    });

    socket.on('playerJoin', (message) {
      print("playerJoin");
      print(message);
      var user = SocketUser.User.fromJson(message);
      players[user.id] = user;
      print(players);
      // notifyListeners();
    });

    socket.on('playerLeave', (message) {
      print("playerLeave");
      print(message);
      var user = SocketUser.User.fromJson(message);
      players.remove(user.id);
      print(players);
      // notifyListeners();
    });

    socket.on('starting', (message) {
      print("starting");
      print(message);
      startCountDown = int.parse(message);
      print(startCountDown);
      state = SessionState.STARTING;
      // notifyListeners();
    });

    socket.on('cancelled', (message) {
      // socket.disconnected;
      print("cancelled");
      socket.disconnect();
      state = SessionState.ABORTED;
      // notifyListeners();
    });

    socket.on('nextQuestion', (message) {
      print("nextQuestion");
      print(message);
      question = questionType.Question(message);
      print(question);
      state = SessionState.QUESTION;
      // notifyListeners();
    });

    socket.on('questionAnswered', (message) {
      print("questionAnswered");
      print(message);
      // questionAnswered.add(message['question']);
      // questionAnswered.add(message['count']);
      // questionAnswered.add(message['total']);
      questionAnswered = QuestionAnswered.fromJson(message);
      print(questionAnswered);
      state = SessionState.QUESTION;
      // notifyListeners();
    });

    socket.on('questionOutcome', (message) {
      print("questionOutcome: ");
      print(message);
      print(userRole);
      if (userRole == GroupRole.OWNER) {
        outcome = Outcome.fromJson(message);
        print(outcome);
      } else {
        outcome = OutcomeUser.fromJson(message);
        print(outcome);
      }
      state = SessionState.OUTCOME;
      // notifyListeners();
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

  void answerQuestion(int questionNo, {List<int> mc, bool tf}) {
    socket.emit('answer',
        {'question': questionNo, 'MCSelection': mc, 'TFSelection': tf});
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

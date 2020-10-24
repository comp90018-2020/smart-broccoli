// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../socket_data/user.dart';
import '../socket_data/question.dart';
import '../socket_data/outcome_host.dart';
import '../socket_data/outcome_user.dart';

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

  List<User> players = []; // all players currently in session (id, name)
  int startCountDown;
  Question question;
  OutcomeHost outcomeHost;
  OutcomeUser outcomeUser;
  List<int> questionAnswered = [];
  int userRole;
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
    userRole = userId;

    socket.on('connect', (message) {
      print('connected');
      // notifyListeners();
    });

    socket.on('welcome', (message) {
      print('welcome');
      print(message);
      message.forEach((player) => players.add(User.fromJson(player)));
      print(players);
      // notifyListeners();
    });

    socket.on('playerJoin', (message) {
      print("playerJoin");
      print(message);
      players.add(User.fromJson(message));
      print(players);
      // notifyListeners();
    });

    socket.on('playerLeave', (message) {
      print("playerLeave");
      print(message);
      for (User player in players) {
        if (User.fromJson(message).id == player.id) {
          players.remove(player);
          break;
        }
      }
      print(players);
      // notifyListeners();
    });

    socket.on('starting', (message) {
      print("starting");
      print(message);
      startCountDown = int.parse(message);
      print(startCountDown);
      // notifyListeners();
    });

    socket.on('cancelled', (message) {
      print("cancelled");
      // notifyListeners();
    });

    socket.on('nextQuestion', (message) {
      print("nextQuestion");
      print(message);
      question = Question(message);
      print(question);
      // notifyListeners();
    });

    socket.on('questionAnswered', (message) {
      print("questionAnswered");
      print(message);
      questionAnswered.add(message['question']);
      questionAnswered.add(message['count']);
      questionAnswered.add(message['total']);
      print(questionAnswered);
      // notifyListeners();
    });

    socket.on('questionOutcome', (message) {
      print("questionOutcome: ");
      print(message);
      print(userRole);
      if (userRole == 1) {
        outcomeHost = OutcomeHost(message);
        print(outcomeHost);
      } else {
        outcomeUser = OutcomeUser(message);
        print(outcomeUser);
      }
      // notifyListeners();
    });
  }

  /// host action
  void startQuiz() {
    socket.emit('start');
  }

  void abortQuiz() {
    socket.emit('abort');
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

  void answerQuestion(dynamic answer) {
    socket.emit('answer', answer);
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

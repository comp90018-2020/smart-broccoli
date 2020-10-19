// import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../data/user.dart';

enum SessionState {
  PENDING,    // in lobby and waiting (unknown how long to start)
  STARTING,   // the quiz will start in a known number of seconds
  QUESTION,   // the quiz is currently on a question
  OUTCOME,    // between questions (leaderboard)
  FINISHED,
  ABORTED,
}

void main(){
  GameSessionModel test = new GameSessionModel();
  test.connect(1, 1);

}

class GameSessionModel {
  // URL of server
  static const String SERVER_URL = 'http://127.0.0.1:3000';

  List<User> players = [];            // all players currently in session (id, name)
  SessionState state;
  // datatype_define_myself(not json) _leaderboard;
  // List<List> _playerRecordJSON;
  // List<List> _playerAnsweredJSON;      //No. players who have answered current question
  // var _playerAheadRecordJSON = jsonEncode(null);
  // int _currentQuestion;
  // int _timeUntilStart;

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
  void connect(int userId, int sessionId) {     //change to token
    // Set query
    socket.opts['query'] = {};
    socket.opts['query']['userId'] = userId;
    print(socket.opts);
    socket.connect();

    // Print on connection
    // socket.on('connect', (_) {
    //   print('connected');
    //
    //   notifyListeners();
    // });

    socket.on('welcome', (message) {
      print('welcome');
      print(message);
      message.forEach((player) => players.add(User.fromJson(player)));
      state = SessionState.PENDING;
      print(players);
      // notifyListener
    });
    //
    // socket.on('playerJoin', (message) {
    //   print("playerJoin");
    //   print(message);
    //   _players.add(message);
    //   _session_State = 'PENDING';
    //   notifyListeners();
    // });
    //
    // socket.on('playerLeave', (message) {
    //   print("playerLeave");
    //   print(message);
    //   // change fields
    //   _players.remove(jsonDecode(message)); // mia
    //   notifyListeners();
    // });
    //
    // socket.on('starting', (message) {
    //   print("starting");
    //   print(message);
    //   // change fields
    //   _session_State = 'STARTING';
    //   _timeUntilStart = (int) message; // ms mia
    //   notifyListeners();
    // });
    //
    // socket.on('cancelled', (message) {
    //   print("cancelled");
    //   print(message);
    //   // change fields
    //   _session_State = 'FINISHED';
    //   // notifyListeners();
    // });
    //
    // socket.on('nextQuestion', (message) {
    //   print("nextQuestion: ");
    //   print(message);
    //   // change fields
    //   _session_State = 'QUESTION';
    //   _currentQuestion = message.question; // mia
    //   notifyListeners();
    // });
    //
    // socket.on('questionAnswered', (message) {
    //   print("questionAnswered: ");
    //   print(message);
    //   // change fields
    //   _playerAnsweredJSON.append(message.user); //mia
    //   notifyListeners();
    // });
    //
    // socket.on('questionOutcome', (message) {
    //   print("questionOutcome: ");
    //   print(message);
    //   // change fields
    //   _session_State = 'OUTCOME';
    //   _leaderboardJSON.append(message); // mia
    //   _leaderboardJSON.sort(); //mia
    //   _playerRecordJSON.refresh(message); // mia
    //   _playerAheadRecordJSON.refresh(message); // mia ??
    //   notifyListeners();
    // });

    // socket.emit("answer");

    // socket.emit("start");
    //
    // socket.emit("next");
    //
    // socket.emit("showBoard");
    //
    // socket.emit("quit");
    //
    // socket.emit("abort");
  }

  /// Subscribe to socket event
  void _subscribe(String event, dynamic Function(dynamic) handler) {
    if (socket.disconnected) {
      throw new Exception("Socket is not connected");
    }
    print('$event has been called');
    socket.on(event, handler);
  }

  /// Emit data to socket
  void _emit(String event, [dynamic data]) {
    if (socket.disconnected) {
      throw new Exception("Socket is not connected");
    }
    socket.emit(data);
  }

  /// Close and dispose all event listeners
  void _disconnect() {
    socket.disconnect();
  }

  /// host action
  void Start_Quiz(int userId){
    // check if need to verify user id
    socket.emit('start');
  }

  void Abort_Quiz(int userId){
    socket.emit('abort');
  }

  void Next_Question(int userId){
    socket.emit('next');
  }

  void Show_Leaderboard(int userId){
    socket.emit('showBoard');
  }

  /// participant action
  void Quit_Quiz(int userId){
    socket.emit('quit');
  }

  void Answer_Question(int userId, dynamic answer){
    socket.emit('answer', answer);
  }

/// get data from socket


// String receive_from_socket(String event, dynamic data){
//
// }
//
// void send_to_socket(String event, dynamic data){
//
// }
}
import 'package:smart_broccoli/src/base/firebase_messages.dart';

class FirebaseSessionHandler {
  SessionStart _sessionStartMessage;
  static final FirebaseSessionHandler _singleton =
      FirebaseSessionHandler._internal();

  FirebaseSessionHandler._internal();

  factory FirebaseSessionHandler() {
    return _singleton;
  }

  void setSessionStartMessage(SessionStart sessionStartMessage) {
    this._sessionStartMessage = sessionStartMessage;
  }

  SessionStart getSessionStartMessage() {
    return this._sessionStartMessage;
  }
}

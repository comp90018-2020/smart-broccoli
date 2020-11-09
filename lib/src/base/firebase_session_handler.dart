import 'package:smart_broccoli/src/base/firebase_messages.dart';

/// Used to temporarily store session notifications on app activation
class FirebaseSessionHandler {
  // The message held interally
  SessionStart _sessionStartMessage;

  // Singleton/constructor
  static final FirebaseSessionHandler _singleton =
      FirebaseSessionHandler._internal();

  FirebaseSessionHandler._internal();

  factory FirebaseSessionHandler() {
    return _singleton;
  }

  // Getters and setters
  void setSessionStartMessage(SessionStart sessionStartMessage) {
    this._sessionStartMessage = sessionStartMessage;
  }

  SessionStart getSessionStartMessage() {
    return this._sessionStartMessage;
  }
}

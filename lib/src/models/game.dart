import 'package:fuzzy_broccoli/models.dart';

enum GameSessionType { INDIVIDUAL, GROUP }
enum GameSessionState { WAITING, ACTIVE, ENDED }

/// Class representing a game session
/// An instance of this class is returned when fetching the user's session from
/// the server via the `QuizModel.getSession` and `QuizModel.joinSession`
/// methods. Additional instances of this class (i.e. not fetched from the
/// server) are to be constructed when the user wants to create new sessions.
/// A new session can be synchronised with the server by passing it to
/// `QuizModel.createSession`.
class GameSession {
  final int id, quizId, groupId;
  final GameSessionType type;
  final GameSessionState state;
  final String joinCode, token;
  final bool groupAutoJoin;

  // Constructor to be used by when the user wants to start a new game session
  factory GameSession(Quiz quiz, GameSessionType sessionType,
          {bool groupAutoJoin = true}) =>
      GameSession._internal(
          null, quiz.id, null, sessionType, null, null, null, groupAutoJoin);

  // Constructor for internal use only
  GameSession._internal(this.id, this.quizId, this.groupId, this.type,
      this.state, this.joinCode, this.token, this.groupAutoJoin);

  factory GameSession.fromJson(Map<String, dynamic> json, {String token}) =>
      GameSession._internal(
          json['id'],
          json['quizId'],
          json['groupId'],
          json['isGroup'] ? GameSessionType.GROUP : GameSessionType.INDIVIDUAL,
          json['state'] == 'waiting'
              ? GameSessionState.WAITING
              : json['state'] == 'active'
                  ? GameSessionState.ACTIVE
                  : GameSessionState.ENDED,
          json['code'],
          token,
          json['subscribeGroup']);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'session': <String, dynamic>{
          'id': id,
          'isGroup': type == GameSessionType.GROUP,
          'state': state == GameSessionState.WAITING
              ? 'waiting'
              : state == GameSessionState.ACTIVE ? 'active' : 'ended',
          'quizId': quizId,
          'groupId': groupId,
          'subscribeGroup': groupAutoJoin,
          'code': joinCode
        },
        'token': token
      };
}

/// Exception thrown when attempting to join another session when already in one
class InSessionException implements Exception {}

/// Exception thrown when attempting to join a session which cannot be found
class SessionNotFoundException implements Exception {}

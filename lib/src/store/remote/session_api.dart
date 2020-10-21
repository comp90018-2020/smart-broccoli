import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:smart_broccoli/src/data/game.dart';
import 'package:smart_broccoli/src/data/quiz.dart';

import 'api_base.dart';

class SessionApi {
  static const SESSION_URL = ApiBase.BASE_URL + '/session';

  /// HTTP client (mock client can be specified for testing)
  http.Client _http;

  SessionApi({http.Client mocker}) {
    _http = mocker ?? IOClient();
  }

  /// Start a new game session.
  ///
  /// Return a `GameSession` object constructed from the server's response.
  Future<GameSession> createSession(
      String token, int quizId, GameSessionType type,
      {bool autoSubscribe = false}) async {
    final http.Response response = await _http.post(SESSION_URL,
        headers: ApiBase.headers(authToken: token),
        body: json.encode({
          "quizId": quizId,
          "isGroup": type == GameSessionType.GROUP,
          "subscribeGroup": autoSubscribe
        }));

    if (response.statusCode == 200) {
      Map resJson = json.decode(response.body);
      return GameSession.fromJson(resJson["session"], token: resJson["token"]);
    }

    if (response.statusCode == 400 &&
        json.decode(response.body)["message"] ==
            "User is already participant of ongoing quiz session")
      throw InSessionException();
    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    if (response.statusCode == 404) throw QuizNotFoundException();
    throw Exception('Unable to create session: unknown error occurred');
  }

  /// Get the user's current session.
  ///
  /// Return `null` if the user has no session.
  Future<GameSession> getSession(String token) async {
    final http.Response response = await _http.get(SESSION_URL,
        headers: ApiBase.headers(authToken: token));

    if (response.statusCode == 200) {
      Map resJson = json.decode(response.body);
      return GameSession.fromJson(resJson["session"], token: resJson["token"]);
    }

    if (response.statusCode == 204) return null;
    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    throw Exception('Unable to get session: unknown error occurred');
  }

  /// Join an existing game session.
  Future<GameSession> joinSession(String token, String joinCode) async {
    final http.Response response = await _http.post('$SESSION_URL/join',
        headers: ApiBase.headers(authToken: token),
        body: json.encode(<String, dynamic>{"code": joinCode}));

    if (response.statusCode == 200) {
      Map resJson = json.decode(response.body);
      return GameSession.fromJson(resJson["session"], token: resJson["token"]);
    }

    if (response.statusCode == 400)
      switch (json.decode(response.body)["message"]) {
        case "User is already participant of ongoing quiz session":
          throw InSessionException();
        case "Session cannot be joined":
          throw SessionNotWaitingException();
      }
    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    if (response.statusCode == 404) throw SessionNotFoundException();
    throw Exception('Unable to join session: unknown error occurred');
  }
}

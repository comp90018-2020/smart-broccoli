import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:smart_broccoli/models.dart';
import 'package:smart_broccoli/src/store/remote/api_base.dart';
import 'package:smart_broccoli/src/store/remote/session_api.dart';

class MockClient extends Mock implements http.Client {}

main() async {
  test('Create session', () async {
    final http.Client client = MockClient();
    final SessionApi api = SessionApi(mocker: client);

    when(client.post(SessionApi.SESSION_URL,
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
            },
            body: isA<String>()))
        .thenAnswer((invocation) async {
      Map<String, dynamic> body =
          json.decode(invocation.namedArguments[Symbol('body')]);

      if (body.containsKey('quizId') &&
          body.containsKey('isGroup') &&
          body.containsKey('subscribeGroup'))
        return http.Response(
            json.encode({
              "session": {
                "id": 1,
                "isGroup": body['isGroup'],
                "type": "live",
                "code": "878838",
                "state": "waiting",
                "subscribeGroup": body['subscribeGroup'],
                "createdAt": "2020-01-01T00:00:00.000Z",
                "updatedAt": "2020-01-01T00:00:00.000Z",
                "quizId": body['quizId'],
                "groupId": 3,
                "Group": {"id": 3, "name": "foo", "defaultGroup": false}
              },
              "token": "thisisagametoken123456789"
            }),
            200);

      return http.Response("", 400);
    });

    final session = await api.createSession(
        "asdfqwerty1234567890foobarbaz", 2, GameSessionType.GROUP,
        autoSubscribe: false);
    expect(session, isA<GameSession>());
    expect(session.id, 1);
    expect(session.quizId, 2);
    expect(session.groupId, 3);
    expect(session.type, GameSessionType.GROUP);
    expect(session.state, GameSessionState.WAITING);
    expect(session.joinCode, "878838");
    expect(session.token, "thisisagametoken123456789");
    expect(session.groupAutoJoin, false);
  });

  test('Create session (user not owner of quiz)', () async {
    final http.Client client = MockClient();
    final SessionApi api = SessionApi(mocker: client);

    when(client.post(SessionApi.SESSION_URL,
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
            },
            body: isA<String>()))
        .thenAnswer((invocation) async {
      Map<String, dynamic> body =
          json.decode(invocation.namedArguments[Symbol('body')]);

      if (body.containsKey('quizId') &&
          body.containsKey('isGroup') &&
          body.containsKey('subscribeGroup'))
        return http.Response(
            json.encode(
                <String, dynamic>{"message": "User cannot access quiz"}),
            403);

      return http.Response("", 400);
    });

    expect(
        () async => await api.createSession(
            "asdfqwerty1234567890foobarbaz", 2, GameSessionType.GROUP,
            autoSubscribe: false),
        throwsA(isA<ForbiddenRequestException>()));
  });

  test('Create session (quiz not found)', () async {
    final http.Client client = MockClient();
    final SessionApi api = SessionApi(mocker: client);

    when(client.post(SessionApi.SESSION_URL,
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
            },
            body: isA<String>()))
        .thenAnswer((invocation) async {
      Map<String, dynamic> body =
          json.decode(invocation.namedArguments[Symbol('body')]);

      if (body.containsKey('quizId') &&
          body.containsKey('isGroup') &&
          body.containsKey('subscribeGroup'))
        return http.Response(
            json.encode(<String, dynamic>{"message": "Quiz not found"}), 404);

      return http.Response("", 400);
    });

    expect(
        () async => await api.createSession(
            "asdfqwerty1234567890foobarbaz", 2, GameSessionType.GROUP,
            autoSubscribe: false),
        throwsA(isA<QuizNotFoundException>()));
  });

  test('Get session', () async {
    final http.Client client = MockClient();
    final SessionApi api = SessionApi(mocker: client);

    when(client.get(SessionApi.SESSION_URL, headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
    })).thenAnswer((_) async => http.Response(
        json.encode(<String, dynamic>{
          "session": <String, dynamic>{
            "id": 1,
            "isGroup": true,
            "type": "live",
            "code": "878838",
            "state": "waiting",
            "subscribeGroup": false,
            "createdAt": "2020-01-01T00:00:00.000Z",
            "updatedAt": "2020-01-01T00:00:00.000Z",
            "quizId": 2,
            "groupId": 3,
            "Group": <String, dynamic>{
              "id": 3,
              "name": "foo",
              "defaultGroup": false
            }
          },
          "token": "thisisagametoken123456789"
        }),
        200));

    final session = await api.getSession("asdfqwerty1234567890foobarbaz");
    expect(session, isA<GameSession>());
    expect(session.id, 1);
    expect(session.quizId, 2);
    expect(session.groupId, 3);
    expect(session.type, GameSessionType.GROUP);
    expect(session.state, GameSessionState.WAITING);
    expect(session.joinCode, "878838");
    expect(session.token, "thisisagametoken123456789");
    expect(session.groupAutoJoin, false);
  });

  test('Get session (user has no session)', () async {
    final http.Client client = MockClient();
    final SessionApi api = SessionApi(mocker: client);

    when(client.get(SessionApi.SESSION_URL, headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
    })).thenAnswer((_) async => http.Response("", 204));

    final session = await api.getSession("asdfqwerty1234567890foobarbaz");
    expect(session, null);
  });

  test('Join session', () async {
    final http.Client client = MockClient();
    final SessionApi api = SessionApi(mocker: client);

    when(client.post('${SessionApi.SESSION_URL}/join',
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
            },
            body: isA<String>()))
        .thenAnswer((invocation) async {
      Map<String, dynamic> body =
          json.decode(invocation.namedArguments[Symbol('body')]);

      if (body.containsKey('code'))
        return http.Response(
            json.encode(<String, dynamic>{
              "session": <String, dynamic>{
                "id": 1,
                "isGroup": true,
                "type": "live",
                "code": body['code'],
                "state": "waiting",
                "subscribeGroup": false,
                "createdAt": "2020-01-01T00:00:00.000Z",
                "updatedAt": "2020-01-01T00:00:00.000Z",
                "quizId": 2,
                "groupId": 3,
                "Group": <String, dynamic>{
                  "id": 3,
                  "name": "foo",
                  "defaultGroup": false
                }
              },
              "token": "thisisagametoken123456789"
            }),
            200);

      return http.Response("", 400);
    });

    final session =
        await api.joinSession("asdfqwerty1234567890foobarbaz", "878838");
    expect(session, isA<GameSession>());
    expect(session.id, 1);
    expect(session.quizId, 2);
    expect(session.groupId, 3);
    expect(session.type, GameSessionType.GROUP);
    expect(session.state, GameSessionState.WAITING);
    expect(session.joinCode, "878838");
    expect(session.token, "thisisagametoken123456789");
    expect(session.groupAutoJoin, false);
  });

  test('Join session (already in a session)', () async {
    final http.Client client = MockClient();
    final SessionApi api = SessionApi(mocker: client);

    when(client.post('${SessionApi.SESSION_URL}/join',
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
            },
            body: isA<String>()))
        .thenAnswer((invocation) async {
      Map<String, dynamic> body =
          json.decode(invocation.namedArguments[Symbol('body')]);

      if (body.containsKey('code'))
        return http.Response(
            json.encode(<String, dynamic>{
              "message": "User is already participant of ongoing quiz session"
            }),
            400);

      return http.Response("", 400);
    });

    expect(
        () async =>
            await api.joinSession("asdfqwerty1234567890foobarbaz", "123456"),
        throwsA(isA<InSessionException>()));
  });

  test('Join session (session not found)', () async {
    final http.Client client = MockClient();
    final SessionApi api = SessionApi(mocker: client);

    when(client.post('${SessionApi.SESSION_URL}/join',
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
            },
            body: isA<String>()))
        .thenAnswer((invocation) async {
      Map<String, dynamic> body =
          json.decode(invocation.namedArguments[Symbol('body')]);

      if (body.containsKey('code'))
        return http.Response(
            json.encode(
                <String, dynamic>{"message": "Cannot find session with code"}),
            404);

      return http.Response("", 400);
    });

    expect(
        () async =>
            await api.joinSession("asdfqwerty1234567890foobarbaz", "000000"),
        throwsA(isA<SessionNotFoundException>()));
  });

  test('Join session (cannot join; already active)', () async {
    final http.Client client = MockClient();
    final SessionApi api = SessionApi(mocker: client);

    when(client.post('${SessionApi.SESSION_URL}/join',
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
            },
            body: isA<String>()))
        .thenAnswer((invocation) async {
      Map<String, dynamic> body =
          json.decode(invocation.namedArguments[Symbol('body')]);

      if (body.containsKey('code'))
        return http.Response(
            json.encode(<String, dynamic>{
              "message": "Session cannot be joined",
              "errors": <String, dynamic>{"state": "active"}
            }),
            400);

      return http.Response("", 400);
    });

    expect(
        () async =>
            await api.joinSession("asdfqwerty1234567890foobarbaz", "123456"),
        throwsA(isA<SessionNotWaitingException>()));
  });
}

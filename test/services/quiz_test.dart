import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fuzzy_broccoli/cache.dart';
import 'package:fuzzy_broccoli/models.dart';
import 'package:fuzzy_broccoli/server.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

class MockClient extends Mock implements http.Client {}

main() async {
  test('Get session', () async {
    final http.Client client = MockClient();
    final AuthModel am = AuthModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final QuizModel qm = QuizModel(am, mocker: client);

    when(client.get(QuizModel.SESSION_URL, headers: anyNamed("headers")))
        .thenAnswer((_) async => http.Response(
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

    final session = await qm.getSession();
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
    final AuthModel am = AuthModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final QuizModel qm = QuizModel(am, mocker: client);

    when(client.get(QuizModel.SESSION_URL, headers: anyNamed("headers")))
        .thenAnswer((_) async => http.Response("", 204));

    final session = await qm.getSession();
    expect(session, null);
  });

  test('Join session', () async {
    final http.Client client = MockClient();
    final AuthModel am = AuthModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final QuizModel qm = QuizModel(am, mocker: client);

    when(client.post('${QuizModel.SESSION_URL}/join',
            headers: anyNamed("headers"), body: anyNamed("body")))
        .thenAnswer((_) async => http.Response(
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

    final session = await qm.joinSession('878838');
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
    final AuthModel am = AuthModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final QuizModel qm = QuizModel(am, mocker: client);

    when(client.post('${QuizModel.SESSION_URL}/join',
            headers: anyNamed("headers"), body: anyNamed("body")))
        .thenAnswer((_) async => http.Response(
            json.encode(<String, dynamic>{
              "message": "User is already participant of ongoing quiz session"
            }),
            400));

    expect(() async => await qm.joinSession('123456'),
        throwsA(isA<InSessionException>()));
  });

  test('Join session (session not found)', () async {
    final http.Client client = MockClient();
    final AuthModel am = AuthModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final QuizModel qm = QuizModel(am, mocker: client);

    when(client.post('${QuizModel.SESSION_URL}/join',
            headers: anyNamed("headers"), body: anyNamed("body")))
        .thenAnswer((_) async => http.Response(
            json.encode(
                <String, dynamic>{"message": "Cannot find session with code"}),
            404));

    expect(() async => await qm.joinSession('000000'),
        throwsA(isA<SessionNotFoundException>()));
  });
}

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fuzzy_broccoli/cache.dart';
import 'package:fuzzy_broccoli/models.dart';
import 'package:fuzzy_broccoli/server.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

class MockClient extends Mock implements http.Client {}

main() async {
  test('Get quizzes', () async {
    final http.Client client = MockClient();
    final AuthModel am = AuthModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final QuizModel qm = QuizModel(am, mocker: client);

    when(client.get(QuizModel.QUIZ_URL, headers: anyNamed("headers")))
        .thenAnswer((_) async => http.Response(
            json.encode([
              {
                "id": 1,
                "title": "foo",
                "active": true,
                "description": "hello world",
                "type": "live",
                "timeLimit": 10,
                "createdAt": "2020-01-01T00:00:00.000Z",
                "updatedAt": "2020-01-01T00:00:00.000Z",
                "pictureId": null,
                "groupId": 2,
                "Sessions": [
                  {
                    "id": 1,
                    "isGroup": false,
                    "type": "live",
                    "code": "107168",
                    "state": "waiting",
                    "subscribeGroup": true
                  }
                ],
                "complete": false,
                "role": "owner"
              },
              {
                "id": 2,
                "title": "bar",
                "active": false,
                "description": null,
                "type": "live",
                "timeLimit": 15,
                "createdAt": "2020-01-01T00:00:00.000Z",
                "updatedAt": "2020-01-01T00:00:00.000Z",
                "pictureId": null,
                "groupId": 2,
                "Sessions": [],
                "complete": false,
                "role": "owner"
              },
              {
                "id": 3,
                "title": "baz",
                "active": true,
                "description": "quiz for your own time",
                "type": "self paced",
                "timeLimit": 20,
                "createdAt": "2020-01-01T00:00:00.000Z",
                "updatedAt": "2020-01-01T00:00:00.000Z",
                "pictureId": null,
                "groupId": 2,
                "Sessions": [
                  {
                    "id": 2,
                    "isGroup": false,
                    "type": "self paced",
                    "code": "878838",
                    "state": "waiting",
                    "subscribeGroup": false
                  },
                  {
                    "id": 3,
                    "isGroup": true,
                    "type": "self paced",
                    "code": "284163",
                    "state": "waiting",
                    "subscribeGroup": false
                  }
                ],
                "complete": false,
                "role": "member"
              }
            ]),
            200));

    final quizzes = await qm.getQuizzes();
    expect(quizzes, isA<List<Quiz>>());
    expect(quizzes.length, 3);
    quizzes.sort((q0, q1) => q0.id.compareTo(q1.id));
    expect(quizzes[0].id, 1);
    expect(quizzes[1].id, 2);
    expect(quizzes[2].id, 3);
    expect(quizzes[0].title, "foo");
    expect(quizzes[1].title, "bar");
    expect(quizzes[2].title, "baz");
    expect(quizzes[0].isActive, true);
    expect(quizzes[1].isActive, false);
    expect(quizzes[2].isActive, true);
    expect(quizzes[0].description, "hello world");
    expect(quizzes[1].description, null);
    expect(quizzes[2].description, "quiz for your own time");
    expect(quizzes[0].type, QuizType.LIVE);
    expect(quizzes[1].type, QuizType.LIVE);
    expect(quizzes[2].type, QuizType.SELF_PACED);
    expect(quizzes[0].timeLimit, 10);
    expect(quizzes[1].timeLimit, 15);
    expect(quizzes[2].timeLimit, 20);
    expect(quizzes[0].groupId, 2);
    expect(quizzes[1].groupId, 2);
    expect(quizzes[2].groupId, 2);
    expect(quizzes[0].sessions, isA<List<GameSession>>());
    expect(quizzes[1].sessions, isA<List<GameSession>>());
    expect(quizzes[2].sessions, isA<List<GameSession>>());
    expect(quizzes[0].sessions.length, 1);
    expect(quizzes[1].sessions.length, 0);
    expect(quizzes[2].sessions.length, 2);
    expect(quizzes[0].sessions[0].id, 1);
    expect(quizzes[2].sessions[0].id, 2);
    expect(quizzes[2].sessions[1].id, 3);
    expect(quizzes[0].sessions[0].quizId, 1);
    expect(quizzes[2].sessions[0].quizId, 3);
    expect(quizzes[2].sessions[1].quizId, 3);
    expect(quizzes[0].sessions[0].groupId, 2);
    expect(quizzes[2].sessions[0].groupId, 2);
    expect(quizzes[2].sessions[1].groupId, 2);
    expect(quizzes[0].sessions[0].type, GameSessionType.INDIVIDUAL);
    expect(quizzes[2].sessions[0].type, GameSessionType.INDIVIDUAL);
    expect(quizzes[2].sessions[1].type, GameSessionType.GROUP);
    expect(quizzes[0].sessions[0].state, GameSessionState.WAITING);
    expect(quizzes[2].sessions[0].state, GameSessionState.WAITING);
    expect(quizzes[2].sessions[1].state, GameSessionState.WAITING);
    expect(quizzes[0].sessions[0].joinCode, "107168");
    expect(quizzes[2].sessions[0].joinCode, "878838");
    expect(quizzes[2].sessions[1].joinCode, "284163");
    expect(quizzes[0].sessions[0].token, null);
    expect(quizzes[2].sessions[0].token, null);
    expect(quizzes[2].sessions[1].token, null);
    expect(quizzes[0].sessions[0].groupAutoJoin, true);
    expect(quizzes[2].sessions[0].groupAutoJoin, false);
    expect(quizzes[2].sessions[1].groupAutoJoin, false);
  });

  test('Get quiz', () async {
    final http.Client client = MockClient();
    final AuthModel am = AuthModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final QuizModel qm = QuizModel(am, mocker: client);

    when(client.get('${QuizModel.QUIZ_URL}/3', headers: anyNamed("headers")))
        .thenAnswer((_) async => http.Response(
            json.encode(<String, dynamic>{
              "id": 3,
              "title": "foo",
              "active": false,
              "description": "lorem ipsum",
              "type": "self paced",
              "timeLimit": 15,
              "createdAt": "2020-01-01T00:00:00.000Z",
              "updatedAt": "2020-01-01T00:00:00.000Z",
              "pictureId": null,
              "groupId": 1,
              "questions": [
                {
                  "id": 2,
                  "text": "blah",
                  "type": "choice",
                  "tf": null,
                  "options": [
                    {"text": "abc", "correct": false},
                    {"text": "xyz", "correct": true}
                  ],
                  "createdAt": "2020-01-01T00:00:00.000Z",
                  "updatedAt": "2020-01-01T00:00:00.000Z",
                  "quizId": 3,
                  "pictureId": null
                },
                {
                  "id": 3,
                  "text": "wowee",
                  "type": "truefalse",
                  "tf": false,
                  "options": null,
                  "createdAt": "2020-01-01T00:00:00.000Z",
                  "updatedAt": "2020-01-01T00:00:00.000Z",
                  "quizId": 3,
                  "pictureId": null
                }
              ],
              "Sessions": [],
              "complete": false
            }),
            200));

    final quiz = await qm.getQuiz(3);
    expect(quiz, isA<Quiz>());
    expect(quiz.id, 3);
    expect(quiz.title, "foo");
    expect(quiz.isActive, false);
    expect(quiz.description, "lorem ipsum");
    expect(quiz.type, QuizType.SELF_PACED);
    expect(quiz.timeLimit, 15);
    expect(quiz.groupId, 1);
    expect(quiz.questions, isA<List<Question>>());
    expect(quiz.questions.length, 2);
    expect(quiz.questions[0], isA<MCQuestion>());
    expect(quiz.questions[1], isA<TFQuestion>());
    expect(
        (quiz.questions[0] as MCQuestion).options, isA<List<QuestionOption>>());
    expect((quiz.questions[0] as MCQuestion).options.length, 2);
    expect((quiz.questions[1] as TFQuestion).answer, false);
    expect(quiz.questions[0].text, "blah");
    expect(quiz.questions[1].text, "wowee");
  });

  test('Get quiz (not found)', () async {
    final http.Client client = MockClient();
    final AuthModel am = AuthModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final QuizModel qm = QuizModel(am, mocker: client);

    when(client.get('${QuizModel.QUIZ_URL}/44', headers: anyNamed("headers")))
        .thenAnswer((_) async => http.Response("", 404));

    expect(() async => await qm.getQuiz(44),
        throwsA(isA<QuizNotFoundException>()));
  });

  test('Get quiz (not accessible to user)', () async {
    final http.Client client = MockClient();
    final AuthModel am = AuthModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final QuizModel qm = QuizModel(am, mocker: client);

    when(client.get('${QuizModel.QUIZ_URL}/44', headers: anyNamed("headers")))
        .thenAnswer((_) async => http.Response("", 403));

    expect(() async => await qm.getQuiz(44),
        throwsA(isA<ForbiddenRequestException>()));
  });

  test('Create session', () async {
    final http.Client client = MockClient();
    final AuthModel am = AuthModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final QuizModel qm = QuizModel(am, mocker: client);

    when(client.post(QuizModel.SESSION_URL,
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

    // pretend user obtained `q` from `getQuizzes` or `getQuiz`
    Quiz q = Quiz.fromJson(<String, dynamic>{
      "id": 2,
      "title": "foo",
      "active": true,
      "description": null,
      "type": "live",
      "timeLimit": 10,
      "createdAt": "2020-01-01T00:00:00.000Z",
      "updatedAt": "2020-01-01T00:00:00.000Z",
      "pictureId": null,
      "groupId": 3,
      "complete": false,
      "role": "owner"
    });

    // user wants to create a session
    GameSession session = GameSession(q, GameSessionType.INDIVIDUAL);

    session = await qm.createSession(session);
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
    final AuthModel am = AuthModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final QuizModel qm = QuizModel(am, mocker: client);

    when(client.post(QuizModel.SESSION_URL,
            headers: anyNamed("headers"), body: anyNamed("body")))
        .thenAnswer((_) async => http.Response(
            json.encode(
                <String, dynamic>{"message": "User cannot access quiz"}),
            403));

    // pretend user obtained `q` from `getQuizzes` or `getQuiz`
    Quiz q = Quiz.fromJson(<String, dynamic>{
      "id": 2,
      "title": "foo",
      "active": true,
      "description": null,
      "type": "live",
      "timeLimit": 10,
      "createdAt": "2020-01-01T00:00:00.000Z",
      "updatedAt": "2020-01-01T00:00:00.000Z",
      "pictureId": null,
      "groupId": 3,
      "complete": false,
      "role": "owner"
    });

    // user wants to create a session
    GameSession session = GameSession(q, GameSessionType.INDIVIDUAL);

    expect(() async => await qm.createSession(session),
        throwsA(isA<ForbiddenRequestException>()));
  });

  test('Create session (quiz not found)', () async {
    final http.Client client = MockClient();
    final AuthModel am = AuthModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final QuizModel qm = QuizModel(am, mocker: client);

    when(client.post(QuizModel.SESSION_URL,
            headers: anyNamed("headers"), body: anyNamed("body")))
        .thenAnswer((_) async => http.Response(
            json.encode(<String, dynamic>{"message": "Quiz not found"}), 404));

    // pretend user obtained `q` from `getQuizzes` or `getQuiz`
    Quiz q = Quiz.fromJson(<String, dynamic>{
      "id": 2,
      "title": "foo",
      "active": true,
      "description": null,
      "type": "live",
      "timeLimit": 10,
      "createdAt": "2020-01-01T00:00:00.000Z",
      "updatedAt": "2020-01-01T00:00:00.000Z",
      "pictureId": null,
      "groupId": 3,
      "complete": false,
      "role": "owner"
    });

    // user wants to create a session
    GameSession session = GameSession(q, GameSessionType.INDIVIDUAL);

    expect(() async => await qm.createSession(session),
        throwsA(isA<QuizNotFoundException>()));
  });

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

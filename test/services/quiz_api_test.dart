import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/store/remote/api_base.dart';
import 'package:smart_broccoli/src/store/remote/quiz_api.dart';

class MockClient extends Mock implements http.Client {}

main() async {
  test('Get quizzes', () async {
    final http.Client client = MockClient();
    final QuizApi api = QuizApi(mocker: client);

    when(client.get(QuizApi.QUIZ_URL, headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
    })).thenAnswer((_) async => http.Response(
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
            "groupId": 3,
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

    final quizzes = await api.getQuizzes("asdfqwerty1234567890foobarbaz");
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
    expect(quizzes[2].groupId, 3);
    expect(quizzes[0].role, GroupRole.OWNER);
    expect(quizzes[1].role, GroupRole.OWNER);
    expect(quizzes[2].role, GroupRole.MEMBER);
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
    expect(quizzes[2].sessions[0].groupId, 3);
    expect(quizzes[2].sessions[1].groupId, 3);
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
    final QuizApi api = QuizApi(mocker: client);

    when(client.get('${QuizApi.QUIZ_URL}/3', headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
    })).thenAnswer((_) async => http.Response(
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

    final quiz = await api.getQuiz("asdfqwerty1234567890foobarbaz", 3);
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
    final QuizApi api = QuizApi(mocker: client);

    when(client.get('${QuizApi.QUIZ_URL}/44', headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
    })).thenAnswer((_) async => http.Response("", 404));

    expect(() async => await api.getQuiz("asdfqwerty1234567890foobarbaz", 44),
        throwsA(isA<QuizNotFoundException>()));
  });

  test('Get quiz (not accessible to user)', () async {
    final http.Client client = MockClient();
    final QuizApi api = QuizApi(mocker: client);

    when(client.get('${QuizApi.QUIZ_URL}/44', headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
    })).thenAnswer((_) async => http.Response("", 403));

    expect(() async => await api.getQuiz("asdfqwerty1234567890foobarbaz", 44),
        throwsA(isA<ForbiddenRequestException>()));
  });

  test('Create quiz', () async {
    final http.Client client = MockClient();
    final QuizApi api = QuizApi(mocker: client);

    when(client.post(QuizApi.QUIZ_URL,
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
            },
            body: isA<String>()))
        .thenAnswer((invocation) async {
      Map<String, dynamic> body =
          json.decode(invocation.namedArguments[Symbol('body')]);

      if (body.containsKey('title') &&
          body.containsKey('groupId') &&
          body.containsKey('type'))
        return http.Response(
            json.encode(<String, dynamic>{
              "active": true,
              "timeLimit": 10,
              "id": 1,
              "groupId": body['groupId'],
              "type": body['type'],
              "title": body['title'],
              "updatedAt": "2020-01-01T00:00:00.000Z",
              "createdAt": "2020-01-01T00:00:00.000Z",
              "description": null,
              "pictureId": null,
              "questions": []
            }),
            201);

      return http.Response("", 400);
    });

    // user creates new quiz
    Quiz quiz = Quiz("foo", 2, QuizType.SELF_PACED);

    quiz = await api.createQuiz("asdfqwerty1234567890foobarbaz", quiz);
    expect(quiz, isA<Quiz>());
    expect(quiz.id, 1);
    expect(quiz.questions, isA<List<Question>>());
    expect(quiz.questions.length, 0);
  });

  test('Delete quiz', () async {
    final http.Client client = MockClient();
    final QuizApi api = QuizApi(mocker: client);

    when(client.delete('${QuizApi.QUIZ_URL}/3', headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
    })).thenAnswer((_) async => http.Response("", 204));

    await api.deleteQuiz("asdfqwerty1234567890foobarbaz", 3);
  });

  test('Delete quiz (not found)', () async {
    final http.Client client = MockClient();
    final QuizApi api = QuizApi(mocker: client);

    when(client.delete('${QuizApi.QUIZ_URL}/3', headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
    })).thenAnswer((_) async => http.Response(
        json.encode(<String, dynamic>{"message": "Quiz not found"}), 404));

    expect(() async => await api.deleteQuiz("asdfqwerty1234567890foobarbaz", 3),
        throwsA(isA<QuizNotFoundException>()));
  });

  test('Delete quiz (not allowed)', () async {
    final http.Client client = MockClient();
    final QuizApi api = QuizApi(mocker: client);

    when(client.delete('${QuizApi.QUIZ_URL}/3', headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
    })).thenAnswer((_) async => http.Response(
        json.encode(<String, dynamic>{"message": "Quiz cannot be accessed"}),
        403));

    expect(() async => await api.deleteQuiz("asdfqwerty1234567890foobarbaz", 3),
        throwsA(isA<ForbiddenRequestException>()));
  });
}

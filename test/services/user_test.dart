import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:smart_broccoli/cache.dart';
import 'package:smart_broccoli/models.dart';

class MockClient extends Mock implements http.Client {}

main() async {
  test('Get registered user profile', () async {
    final http.Client client = MockClient();
    final AuthStateModel am = AuthStateModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final UserStateModel um = UserStateModel(am, mocker: client);

    when(client.get('${UserStateModel.USER_URL}/profile',
            headers: anyNamed("headers")))
        .thenAnswer((_) async => http.Response(
            json.encode(<String, dynamic>{
              "id": 1,
              "email": "foo@bar.com",
              "name": "Foo Bar",
              "role": "user",
              "pictureId": null,
              "createdAt": "2020-01-01T00:00:00.000Z",
              "updatedAt": "2020-01-01T00:00:00.000Z"
            }),
            200));
    final user = await um.getUser();
    expect(user, isA<RegisteredUser>());
    expect(user.id, 1);
    expect(user.email, "foo@bar.com");
    expect(user.name, "Foo Bar");
  });

  test('Get participant user profile', () async {
    final http.Client client = MockClient();
    final AuthStateModel am = AuthStateModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final UserStateModel um = UserStateModel(am, mocker: client);

    when(client.get('${UserStateModel.USER_URL}/profile',
            headers: anyNamed("headers")))
        .thenAnswer((_) async => http.Response(
            json.encode(<String, dynamic>{
              "id": 1,
              "email": "foo@bar.com",
              "name": "Foo Bar",
              "role": "participant",
              "pictureId": null,
              "createdAt": "2020-01-01T00:00:00.000Z",
              "updatedAt": "2020-01-01T00:00:00.000Z"
            }),
            200));
    final user = await um.getUser();
    expect(user, isA<ParticipantUser>());
    expect(user.id, 1);
    expect(user.email, "foo@bar.com");
    expect(user.name, "Foo Bar");
  });

  test('Get user profile (token revoked)', () async {
    final http.Client client = MockClient();
    final AuthStateModel am = AuthStateModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final UserStateModel um = UserStateModel(am, mocker: client);

    when(client.get('${UserStateModel.USER_URL}/profile',
            headers: anyNamed("headers")))
        .thenAnswer((_) async => http.Response(
            json.encode(
                <String, dynamic>{"message": "Token revoked or missing"}),
            403));
    expect(() async => await um.getUser(),
        throwsA(isA<ForbiddenRequestException>()));
  });

  test('Get other user profile (using session token)', () async {
    final http.Client client = MockClient();
    final AuthModel am = AuthModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final UserModel um = UserModel(am, mocker: client);

    when(client.get('${UserModel.USER_URL}/1/profile', headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer thisisagametoken123456789'
    })).thenAnswer((_) async => http.Response(
        json.encode(<String, dynamic>{
          "id": 1,
          "name": "Foo Bar",
          "updatedAt": "2020-01-01T00:00:00.000Z"
        }),
        200));

    // pretend client obtained `s` from `QuizModel.getSession` or
    // `QuizModel.joinSession`
    GameSession s = GameSession.fromJson(<String, dynamic>{
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
      "Group": <String, dynamic>{"id": 3, "name": "foo", "defaultGroup": false}
    }, token: "thisisagametoken123456789");
    expect(s.token, "thisisagametoken123456789");

    final user = await um.getUser(id: 1, session: s);
    expect(user, isA<User>());
    expect(user.id, 1);
    expect(user.name, "Foo Bar");
  });

  test('Get other user profile (without session token)', () async {
    final http.Client client = MockClient();
    final AuthModel am = AuthModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final UserModel um = UserModel(am, mocker: client);

    when(client.get('${UserModel.USER_URL}/1/profile', headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
    })).thenAnswer((_) async => http.Response(
        json.encode(<String, dynamic>{
          "id": 1,
          "name": "Foo Bar",
          "updatedAt": "2020-01-01T00:00:00.000Z"
        }),
        200));

    final user = await um.getUser(id: 1);
    expect(user, isA<User>());
    expect(user.id, 1);
    expect(user.name, "Foo Bar");
  });

  test('Update user profile', () async {
    final http.Client client = MockClient();
    final AuthStateModel am = AuthStateModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final UserStateModel um = UserStateModel(am, mocker: client);

    when(client.patch('${UserStateModel.USER_URL}/profile',
            headers: anyNamed("headers"), body: anyNamed("body")))
        .thenAnswer((_) async => http.Response(
            json.encode(<String, dynamic>{
              "id": 1,
              "email": "aharwood@unimelb.com",
              "name": "Aaron Harwood",
              "role": "user",
              "pictureId": null,
              "createdAt": "2020-01-01T00:00:00.000Z",
              "updatedAt": "2020-01-01T00:00:00.000Z"
            }),
            200));
    final user = await um
        .updateUser(RegisteredUser(1, "aharwood@unimelb.com", "Aaron Harwood"));
    expect(user, isA<RegisteredUser>());
    expect(user.id, 1);
    expect(user.email, "aharwood@unimelb.com");
    expect(user.name, "Aaron Harwood");
  });

  test('Update user profile (email conflict)', () async {
    final http.Client client = MockClient();
    final AuthStateModel am = AuthStateModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final UserStateModel um = UserStateModel(am, mocker: client);

    when(client.patch('${UserStateModel.USER_URL}/profile',
            headers: anyNamed("headers"), body: anyNamed("body")))
        .thenAnswer((_) async => http.Response(
            json.encode(<String, dynamic>{
              "message": "Validation error",
              "errors": [
                <String, dynamic>{
                  "msg": "Uniqueness constraint failure",
                  "location": "body",
                  "param": "email"
                }
              ]
            }),
            409));
    expect(
        () async => await um.updateUser(
            RegisteredUser(1, "aharwood@unimelb.com", "Aaron Harwood")),
        throwsA(isA<RegistrationConflictException>()));
  });

  test('Get profile picture (exists)', () async {
    final http.Client client = MockClient();
    final AuthStateModel am = AuthStateModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final UserStateModel um = UserStateModel(am, mocker: client);

    when(client.get('${UserStateModel.USER_URL}/profile/picture',
            headers: anyNamed("headers")))
        .thenAnswer((_) async =>
            http.Response(Uint8List.fromList([1, 2, 3, 4, 5]).toString(), 200));
    final pic = await um.getProfilePic();
    expect(pic, isA<Uint8List>());
  });

  test('Get profile picture (does not exist)', () async {
    final http.Client client = MockClient();
    final AuthStateModel am = AuthStateModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final UserStateModel um = UserStateModel(am, mocker: client);

    when(client.get('${UserStateModel.USER_URL}/profile/picture',
            headers: anyNamed("headers")))
        .thenAnswer((_) async => http.Response(
            json.encode(<String, dynamic>{"message": "Picture not found"}),
            404));
    final pic = await um.getProfilePic();
    expect(pic, null);
  });

  test('Delete profile picture', () async {
    final http.Client client = MockClient();
    final AuthStateModel am = AuthStateModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final UserStateModel um = UserStateModel(am, mocker: client);

    when(client.delete('${UserStateModel.USER_URL}/profile/picture',
            headers: anyNamed("headers")))
        .thenAnswer((_) async => http.Response("", 204));
    await um.deleteProfilePic();
  });

  test('Delete profile picture (server error)', () async {
    final http.Client client = MockClient();
    final AuthStateModel am = AuthStateModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final UserStateModel um = UserStateModel(am, mocker: client);

    when(client.delete('${UserStateModel.USER_URL}/profile/picture',
            headers: anyNamed("headers")))
        .thenAnswer((_) async => http.Response(
            json.encode(<String, dynamic>{"message": "Something went wrong"}),
            500));
    expect(() async => await um.deleteProfilePic(), throwsException);
  });

  test('Get other user profile picture (using session token)', () async {
    final http.Client client = MockClient();
    final AuthModel am = AuthModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final UserModel um = UserModel(am, mocker: client);

    when(client.get('${UserModel.USER_URL}/1/profile/picture', headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer thisisagametoken123456789'
    })).thenAnswer((_) async =>
        http.Response(Uint8List.fromList([1, 2, 3, 4, 5]).toString(), 200));

    // pretend client obtained `s` from `QuizModel.getSession` or
    // `QuizModel.joinSession`
    GameSession s = GameSession.fromJson(<String, dynamic>{
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
      "Group": <String, dynamic>{"id": 3, "name": "foo", "defaultGroup": false}
    }, token: "thisisagametoken123456789");
    expect(s.token, "thisisagametoken123456789");

    final pic = await um.getProfilePic(id: 1, session: s);
    expect(pic, isA<Uint8List>());
  });

  test('Get other user profile picture (without session token)', () async {
    final http.Client client = MockClient();
    final AuthModel am = AuthModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final UserModel um = UserModel(am, mocker: client);

    when(client.get('${UserModel.USER_URL}/1/profile/picture', headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
    })).thenAnswer((_) async =>
        http.Response(Uint8List.fromList([1, 2, 3, 4, 5]).toString(), 200));

    final pic = await um.getProfilePic(id: 1);
    expect(pic, isA<Uint8List>());
  });
}

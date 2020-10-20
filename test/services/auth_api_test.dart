import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

import 'package:smart_broccoli/src/data/user.dart';
import 'package:smart_broccoli/src/store/remote/auth_api.dart';

class MockClient extends Mock implements http.Client {}

main() async {
  test('Register user', () async {
    final http.Client client = MockClient();
    final AuthApi api = AuthApi(mocker: client);

    when(client.post('${AuthApi.AUTH_URL}/register',
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: isA<String>()))
        .thenAnswer((invocation) async {
      final Map<String, dynamic> body =
          json.decode(invocation.namedArguments[Symbol('body')]);

      if (body.containsKey('email') &&
          body.containsKey('name') &&
          body.containsKey('password') &&
          body['password'].length >= 8)
        return http.Response(
            json.encode({
              "id": 1,
              "email": body['email'],
              "name": body['name'],
              "role": "user",
              "updatedAt": "2020-01-01T00:00:00.000Z",
              "createdAt": "2020-01-01T00:00:00.000Z",
              "pictureId": null
            }),
            201);

      return http.Response("", 400);
    });

    final user = await api.register("foo@bar.com", "helloworld", "Foo Bar");
    expect(user, isA<User>());
    expect(user.type, UserType.REGISTERED);
    expect(user.id, 1);
    expect(user.email, "foo@bar.com");
    expect(user.name, "Foo Bar");
  });

  test('Register user with email conflict', () async {
    final http.Client client = MockClient();
    final AuthApi api = AuthApi(mocker: client);

    when(client.post('${AuthApi.AUTH_URL}/register',
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: isA<String>()))
        .thenAnswer((invocation) async {
      final Map<String, dynamic> body =
          json.decode(invocation.namedArguments[Symbol('body')]);

      if (body.containsKey('email') &&
          body.containsKey('name') &&
          body.containsKey('password') &&
          body['password'].length >= 8)
        return http.Response(
            json.encode({
              "message": "Validation error",
              "errors": [
                {
                  "msg": "Uniqueness constraint failure",
                  "location": "body",
                  "param": "email"
                }
              ]
            }),
            409);

      return http.Response("", 400);
    });

    expect(
        () async => await api.register("foo@bar.com", "helloworld", "Foo Bar"),
        throwsA(isA<RegistrationConflictException>()));
  });

  test('Join', () async {
    final http.Client client = MockClient();
    final AuthApi api = AuthApi(mocker: client);

    when(client.post('${AuthApi.AUTH_URL}/join',
            headers: {'Content-Type': 'application/json; charset=UTF-8'}))
        .thenAnswer((_) async => http.Response(
            json.encode({"token": "asdfqwerty1234567890foobarbaz"}), 200));

    expect(await api.join(), "asdfqwerty1234567890foobarbaz");
  });

  test('Join (server refusal)', () async {
    final http.Client client = MockClient();
    final AuthApi api = AuthApi(mocker: client);

    when(client.post('${AuthApi.AUTH_URL}/join',
            headers: {'Content-Type': 'application/json; charset=UTF-8'}))
        .thenAnswer((_) async =>
            http.Response(json.encode({"message": "An error occurred"}), 400));

    expect(
        () async => await api.join(), throwsA(isA<ParticipantJoinException>()));
  });

  test('Login', () async {
    final http.Client client = MockClient();
    final AuthApi api = AuthApi(mocker: client);

    when(client.post('${AuthApi.AUTH_URL}/login',
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: isA<String>()))
        .thenAnswer((invocation) async {
      Map<String, dynamic> body =
          json.decode(invocation.namedArguments[Symbol('body')]);

      if (body.containsKey('email') && body.containsKey('password'))
        return http.Response(
            json.encode({"token": "asdfqwerty1234567890foobarbaz"}), 200);

      return http.Response("", 400);
    });

    expect(await api.login("foo@bar.com", "helloworld"),
        "asdfqwerty1234567890foobarbaz");
  });

  test('Login bad creds', () async {
    final http.Client client = MockClient();
    final AuthApi api = AuthApi(mocker: client);
    when(client.post('${AuthApi.AUTH_URL}/login',
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: isA<String>()))
        .thenAnswer((invocation) async {
      Map<String, dynamic> body =
          json.decode(invocation.namedArguments[Symbol('body')]);

      if (body.containsKey('email') && body.containsKey('password'))
        return http.Response(
            json.encode({"message": "Incorrect email/password"}), 403);

      return http.Response("", 400);
    });

    expect(() async => await api.login("foo@bar.com", "wrongpassword"),
        throwsA(isA<LoginFailedException>()));
  });

  test('Valid session', () async {
    final http.Client client = MockClient();
    final AuthApi api = AuthApi(mocker: client);

    when(client.get('${AuthApi.AUTH_URL}/session', headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
    })).thenAnswer((_) async => http.Response("", 200));

    expect(await api.sessionIsValid("asdfqwerty1234567890foobarbaz"), true);
  });

  test('Invalid session', () async {
    final http.Client client = MockClient();
    final AuthApi api = AuthApi(mocker: client);

    when(client.get('${AuthApi.AUTH_URL}/session', headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
    })).thenAnswer((_) async => http.Response(
        json.encode(<String, dynamic>{"message": "Token revoked or missing"}),
        403));

    expect(await api.sessionIsValid("asdfqwerty1234567890foobarbaz"), false);
  });

  test('Logout (server notifies successful)', () async {
    final http.Client client = MockClient();
    final AuthApi api = AuthApi(mocker: client);

    when(client.post('${AuthApi.AUTH_URL}/logout', headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
    })).thenAnswer((_) async => http.Response("", 200));

    expect(await api.logout("asdfqwerty1234567890foobarbaz"), true);
  });

  test('Logout (server notifies unsuccessful)', () async {
    final http.Client client = MockClient();
    AuthApi am = AuthApi(mocker: client);

    when(client.post('${AuthApi.AUTH_URL}/logout', headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
    })).thenAnswer((_) async => http.Response(
        json.encode(<String, dynamic>{"message": "Token revoked or missing"}),
        403));

    expect(await am.logout("asdfqwerty1234567890foobarbaz"), false);
  });
}

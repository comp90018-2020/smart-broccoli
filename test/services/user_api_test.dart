import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

import 'package:smart_broccoli/src/data/user.dart';
import 'package:smart_broccoli/src/store/remote/api_base.dart';
import 'package:smart_broccoli/src/store/remote/user_api.dart';

class MockClient extends Mock implements http.Client {}

main() async {
  test('Get registered user profile', () async {
    final http.Client client = MockClient();
    final UserApi api = UserApi(mocker: client);

    when(client.get('${UserApi.USER_URL}/profile', headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
    })).thenAnswer((_) async => http.Response(
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
    final user = await api.getUser("asdfqwerty1234567890foobarbaz");
    expect(user, isA<User>());
    expect(user.type, UserType.REGISTERED);
    expect(user.id, 1);
    expect(user.email, "foo@bar.com");
    expect(user.name, "Foo Bar");
  });

  test('Get participant user profile', () async {
    final http.Client client = MockClient();
    final UserApi api = UserApi(mocker: client);

    when(client.get('${UserApi.USER_URL}/profile', headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
    })).thenAnswer((_) async => http.Response(
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
    final user = await api.getUser("asdfqwerty1234567890foobarbaz");
    expect(user, isA<User>());
    expect(user.type, UserType.UNREGISTERED);
    expect(user.id, 1);
    expect(user.email, "foo@bar.com");
    expect(user.name, "Foo Bar");
  });

  test('Get user profile (token revoked)', () async {
    final http.Client client = MockClient();
    final UserApi api = UserApi(mocker: client);

    when(client.get('${UserApi.USER_URL}/profile', headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
    })).thenAnswer((_) async => http.Response(
        json.encode(<String, dynamic>{"message": "Token revoked or missing"}),
        403));
    expect(() async => await api.getUser("asdfqwerty1234567890foobarbaz"),
        throwsA(isA<ForbiddenRequestException>()));
  });

  test('Update user profile', () async {
    final http.Client client = MockClient();
    final UserApi api = UserApi(mocker: client);

    when(client.patch('${UserApi.USER_URL}/profile',
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
            },
            body: isA<String>()))
        .thenAnswer((invocation) async {
      Map<String, dynamic> body =
          json.decode(invocation.namedArguments[Symbol('body')]);

      return http.Response(
          json.encode(<String, dynamic>{
            "id": 1,
            "email": body['email'],
            "name": body['name'],
            "role": "user",
            "pictureId": null,
            "createdAt": "2020-01-01T00:00:00.000Z",
            "updatedAt": "2020-01-01T00:00:00.000Z"
          }),
          200);
    });
    final user = await api.updateUser("asdfqwerty1234567890foobarbaz",
        email: "aharwood@unimelb.com", name: "Aaron Harwood");
    expect(user, isA<User>());
    expect(user.type, UserType.REGISTERED);
    expect(user.id, 1);
    expect(user.email, "aharwood@unimelb.com");
    expect(user.name, "Aaron Harwood");
  });

  test('Update user profile (email conflict)', () async {
    final http.Client client = MockClient();
    final UserApi api = UserApi(mocker: client);

    when(client.patch('${UserApi.USER_URL}/profile',
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
            },
            body: isA<String>()))
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
        () async => await api.updateUser("asdfqwerty1234567890foobarbaz",
            email: "aharwood@unimelb.com", name: "Aaron Harwood"),
        throwsA(isA<RegistrationConflictException>()));
  });

  test('Get profile picture (exists)', () async {
    final http.Client client = MockClient();
    final UserApi api = UserApi(mocker: client);

    when(client.get('${UserApi.USER_URL}/profile/picture', headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
    })).thenAnswer(
        (_) async => http.Response(utf8.decode([1, 2, 3, 4, 5]), 200));
    final pic = await api.getProfilePic("asdfqwerty1234567890foobarbaz");
    expect(pic, isA<Uint8List>());
    expect(pic, [1, 2, 3, 4, 5]);
  });

  test('Get profile picture (does not exist)', () async {
    final http.Client client = MockClient();
    final UserApi api = UserApi(mocker: client);

    when(client.get('${UserApi.USER_URL}/profile/picture', headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
    })).thenAnswer((_) async => http.Response(
        json.encode(<String, dynamic>{"message": "Picture not found"}), 404));
    final pic = await api.getProfilePic("asdfqwerty1234567890foobarbaz");
    expect(pic, null);
  });

  test('Delete profile picture', () async {
    final http.Client client = MockClient();
    final UserApi um = UserApi(mocker: client);

    when(client.delete('${UserApi.USER_URL}/profile/picture', headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
    })).thenAnswer((_) async => http.Response("", 204));
    await um.deleteProfilePic("asdfqwerty1234567890foobarbaz");
  });

  test('Delete profile picture (server error)', () async {
    final http.Client client = MockClient();
    final UserApi um = UserApi(mocker: client);

    when(client.delete('${UserApi.USER_URL}/profile/picture', headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
    })).thenAnswer((_) async => http.Response(
        json.encode(<String, dynamic>{"message": "Something went wrong"}),
        500));
    expect(
        () async => await um.deleteProfilePic("asdfqwerty1234567890foobarbaz"),
        throwsException);
  });
}

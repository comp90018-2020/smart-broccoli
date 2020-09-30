import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:fuzzy_broccoli/cache.dart';
import 'package:fuzzy_broccoli/models.dart';
import 'package:fuzzy_broccoli/server.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

class MockClient extends Mock implements http.Client {}

main() async {
  test('Get registered user profile', () async {
    final http.Client client = MockClient();
    AuthModel am = AuthModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    UserModel um = UserModel(am, mocker: client);

    when(client.get('${UserModel.USER_URL}/profile',
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
    AuthModel am = AuthModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    UserModel um = UserModel(am, mocker: client);

    when(client.get('${UserModel.USER_URL}/profile',
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

  test('Get profile picture (exists)', () async {
    final http.Client client = MockClient();
    AuthModel am = AuthModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    UserModel um = UserModel(am, mocker: client);

    when(client.get('${UserModel.USER_URL}/profile/picture',
            headers: anyNamed("headers")))
        .thenAnswer((_) async =>
            http.Response(Uint8List.fromList([1, 2, 3, 4, 5]).toString(), 200));
    final pic = await um.getProfilePic();
    expect(pic, isA<Uint8List>());
  });

  test('Get profile picture (does not exist)', () async {
    final http.Client client = MockClient();
    AuthModel am = AuthModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    UserModel um = UserModel(am, mocker: client);

    when(client.get('${UserModel.USER_URL}/profile/picture',
            headers: anyNamed("headers")))
        .thenAnswer((_) async => http.Response(
            json.encode(<String, dynamic>{"message": "Picture not found"}),
            404));
    final pic = await um.getProfilePic();
    expect(pic, null);
  });
}

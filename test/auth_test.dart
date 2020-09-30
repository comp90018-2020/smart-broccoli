import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fuzzy_broccoli/cache.dart';
import 'package:fuzzy_broccoli/models.dart';
import 'package:fuzzy_broccoli/server.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

class MockClient extends Mock implements http.Client {}

main() async {
  test('Register user', () async {
    final http.Client client = MockClient();
    AuthModel am = AuthModel(MainMemKeyValueStore(), mocker: client);

    when(client.post('${AuthModel.AUTH_URL}/register',
            headers: anyNamed("headers"), body: anyNamed("body")))
        .thenAnswer((_) async => http.Response(
            json.encode(<String, dynamic>{
              "id": 1,
              "email": "foo@bar.com",
              "name": "Foo Bar",
              "role": "user",
              "updatedAt": "2020-01-01T00:00:00.000Z",
              "createdAt": "2020-01-01T00:00:00.000Z",
              "pictureId": null
            }),
            201));

    RegisteredUser user =
        await am.register("foo@bar.com", "helloworld", "Foo Bar");
    expect(user.id, 1);
    expect(user.email, "foo@bar.com");
    expect(user.name, "Foo Bar");
  });

  test('Join', () async {
    final http.Client client = MockClient();
    AuthModel am = AuthModel(MainMemKeyValueStore(), mocker: client);

    when(client.post('${AuthModel.AUTH_URL}/join',
            headers: anyNamed("headers")))
        .thenAnswer((_) async => http.Response(
            json.encode(
                <String, dynamic>{"token": "asdfqwerty1234567890foobarbaz"}),
            200));

    await am.join();
    expect(am.inSession(), true);
  });

  test('Join (server refusal)', () async {
    final http.Client client = MockClient();
    AuthModel am = AuthModel(MainMemKeyValueStore(), mocker: client);

    when(client.post('${AuthModel.AUTH_URL}/join',
            headers: anyNamed("headers")))
        .thenAnswer((_) async => http.Response(
            json.encode(
                <String, dynamic>{"message": "An error occurred"}),
            400));

    expect(() async => await am.join(), throwsException);
    expect(am.inSession(), false);
  });
}

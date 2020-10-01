import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fuzzy_broccoli/cache.dart';
import 'package:fuzzy_broccoli/models.dart';
import 'package:fuzzy_broccoli/server.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

class MockClient extends Mock implements http.Client {}

main() async {
  test('Create group', () async {
    final http.Client client = MockClient();
    final AuthModel am = AuthModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final GroupModel gm = GroupModel(am, mocker: client);

    when(client.post(GroupModel.GROUP_URL,
            headers: anyNamed("headers"), body: anyNamed("body")))
        .thenAnswer((_) async => http.Response(
            json.encode(<String, dynamic>{
              "code": "abc123",
              "id": 10,
              "name": "Lorem ipsum",
              "defaultGroup": false,
              "updatedAt": "2020-01-01T00:00:00.000Z",
              "createdAt": "2020-01-01T00:00:00.000Z"
            }),
            201));

    final g = await gm.createGroup('Lorem ipsum');
    expect(g, isA<Group>());
    expect(g.id, 10);
    expect(g.code, "abc123");
    expect(g.name, "Lorem ipsum");
    expect(g.defaultGroup, false);
    expect(g.members, null);
  });
}

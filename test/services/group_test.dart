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

  test('Create group (name already taken)', () async {
    final http.Client client = MockClient();
    final AuthModel am = AuthModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final GroupModel gm = GroupModel(am, mocker: client);

    when(client.post(GroupModel.GROUP_URL,
            headers: anyNamed("headers"), body: anyNamed("body")))
        .thenAnswer((_) async => http.Response(
            json.encode(<String, dynamic>{
              "message": "Validation error",
              "errors": [
                <String, dynamic>{
                  "msg": "Uniqueness constraint failure",
                  "location": "body",
                  "param": "name"
                }
              ]
            }),
            409));

    expect(() async => await gm.createGroup('Lorem ipsum'),
        throwsA(isA<GroupCreateException>()));
  });

  test('Get groups', () async {
    final http.Client client = MockClient();
    final AuthModel am = AuthModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final GroupModel gm = GroupModel(am, mocker: client);

    when(client.get(GroupModel.GROUP_URL, headers: anyNamed("headers")))
        .thenAnswer((_) async => http.Response(
            json.encode([
              <String, dynamic>{
                "id": 1,
                "name": "Foo Bar",
                "createdAt": "2020-01-01T00:00:00.000Z",
                "updatedAt": "2020-01-01T00:00:00.000Z",
                "defaultGroup": true,
                "code": "Hq6PP5",
                "role": "owner"
              },
              <String, dynamic>{
                "id": 2,
                "name": "lorem",
                "createdAt": "2020-01-01T00:00:00.000Z",
                "updatedAt": "2020-01-01T00:00:00.000Z",
                "defaultGroup": false,
                "code": "BG1egA",
                "role": "owner"
              },
              <String, dynamic>{
                "id": 3,
                "name": "ipsum",
                "createdAt": "2020-01-01T00:00:00.000Z",
                "updatedAt": "2020-01-01T00:00:00.000Z",
                "defaultGroup": false,
                "code": "DKeBBJ",
                "role": "member"
              }
            ]),
            200));

    final groups = await gm.getGroups();
    expect(groups, isA<List<Group>>());
    expect(groups.length, 3);
    groups.sort((g0, g1) => g0.id.compareTo(g1.id));
    expect(groups[0].id, 1);
    expect(groups[1].id, 2);
    expect(groups[2].id, 3);
    expect(groups[0].name, "Foo Bar");
    expect(groups[1].name, "lorem");
    expect(groups[2].name, "ipsum");
    expect(groups[0].defaultGroup, true);
    expect(groups[1].defaultGroup, false);
    expect(groups[2].defaultGroup, false);
    expect(groups[0].code, "Hq6PP5");
    expect(groups[1].code, "BG1egA");
    expect(groups[2].code, "DKeBBJ");
  });

  test('Get specified group', () async {
    final http.Client client = MockClient();
    final AuthModel am = AuthModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final GroupModel gm = GroupModel(am, mocker: client);

    when(client.get('${GroupModel.GROUP_URL}/2', headers: anyNamed("headers")))
        .thenAnswer((_) async => http.Response(
            json.encode(<String, dynamic>{
              "id": 2,
              "name": "foo",
              "createdAt": "2020-01-01T00:00:00.000Z",
              "updatedAt": "2020-01-01T00:00:00.000Z",
              "defaultGroup": false,
              "code": "BG1egA",
              "role": "owner"
            }),
            200));

    final group = await gm.getGroup(2);
    expect(group, isA<Group>());
    expect(group.id, 2);
    expect(group.name, "foo");
    expect(group.defaultGroup, false);
    expect(group.code, "BG1egA");
  });
}

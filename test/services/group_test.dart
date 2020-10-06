import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_broccoli/cache.dart';
import 'package:smart_broccoli/models.dart';
import 'package:smart_broccoli/server.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:tuple/tuple.dart';

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

  test('Get members of specified group', () async {
    final http.Client client = MockClient();
    final AuthModel am = AuthModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final GroupModel gm = GroupModel(am, mocker: client);

    when(client.get('${GroupModel.GROUP_URL}/2/member',
            headers: anyNamed("headers")))
        .thenAnswer((_) async => http.Response(
            json.encode([
              {
                "id": 1,
                "updatedAt": "2020-01-01T00:00:00.000Z",
                "name": "Harald Søndergaard",
                "role": "owner"
              },
              {
                "id": 2,
                "updatedAt": "2020-01-01T00:00:00.000Z",
                "name": "Aaron Harwood",
                "role": "member"
              },
              {
                "id": 3,
                "updatedAt": "2020-01-01T00:00:00.000Z",
                "name": null,
                "role": "member"
              }
            ]),
            200));

    // pretend client obtained `g` was from `getGroup` or `getGroups`
    Group g = Group.fromJson(<String, dynamic>{
      "id": 2,
      "name": "foo",
      "createdAt": "2020-01-01T00:00:00.000Z",
      "updatedAt": "2020-01-01T00:00:00.000Z",
      "defaultGroup": false,
      "code": "BG1egA",
      "role": "owner"
    });

    await gm.getMembers(g);
    expect(g.members, isA<List<Tuple2<User, GroupRole>>>());
    expect(g.members.length, 3);
    g.members.sort((t0, t1) => t0.item1.id.compareTo(t1.item1.id));
    expect(g.members[0].item1.id, 1);
    expect(g.members[1].item1.id, 2);
    expect(g.members[2].item1.id, 3);
    expect(g.members[0].item1.name, "Harald Søndergaard");
    expect(g.members[1].item1.name, "Aaron Harwood");
    expect(g.members[2].item1.name, null);
    expect(g.members[0].item2, GroupRole.OWNER);
    expect(g.members[1].item2, GroupRole.MEMBER);
    expect(g.members[2].item2, GroupRole.MEMBER);
  });

  test('Get specified group (does not exist)', () async {
    final http.Client client = MockClient();
    final AuthModel am = AuthModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final GroupModel gm = GroupModel(am, mocker: client);

    when(client.get('${GroupModel.GROUP_URL}/44', headers: anyNamed("headers")))
        .thenAnswer((_) async => http.Response(
            json.encode(<String, dynamic>{"message": "Group not found"}), 404));

    expect(() async => await gm.getGroup(44),
        throwsA(isA<GroupNotFoundException>()));
  });

  test('Update group', () async {
    final http.Client client = MockClient();
    final AuthModel am = AuthModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final GroupModel gm = GroupModel(am, mocker: client);

    when(client.patch('${GroupModel.GROUP_URL}/2',
            headers: anyNamed("headers"), body: anyNamed("body")))
        .thenAnswer((_) async => http.Response(
            json.encode(<String, dynamic>{
              "id": 2,
              "name": "new",
              "createdAt": "2020-01-01T00:00:00.000Z",
              "updatedAt": "2020-01-01T00:00:00.000Z",
              "defaultGroup": false,
              "code": "BG1egA",
              "role": "owner"
            }),
            200));

    // pretend client obtained `g` was from `getGroup` or `getGroups`
    Group g = Group.fromJson(<String, dynamic>{
      "id": 2,
      "name": "foo",
      "createdAt": "2020-01-01T00:00:00.000Z",
      "updatedAt": "2020-01-01T00:00:00.000Z",
      "defaultGroup": false,
      "code": "BG1egA",
      "role": "owner"
    });
    // client updates name of group
    g.name = "new";

    final returned = await gm.updateGroup(g);
    expect(returned, isA<Group>());
    expect(returned.id, 2);
    expect(returned.name, "new");
    expect(returned.defaultGroup, false);
    expect(returned.code, "BG1egA");
  });

  test('Delete group', () async {
    final http.Client client = MockClient();
    final AuthModel am = AuthModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final GroupModel gm = GroupModel(am, mocker: client);

    when(client.delete('${GroupModel.GROUP_URL}/2',
            headers: anyNamed("headers")))
        .thenAnswer((_) async => http.Response("", 204));

    // pretend client obtained `g` was from `getGroup` or `getGroups`
    Group g = Group.fromJson(<String, dynamic>{
      "id": 2,
      "name": "foo",
      "createdAt": "2020-01-01T00:00:00.000Z",
      "updatedAt": "2020-01-01T00:00:00.000Z",
      "defaultGroup": false,
      "code": "BG1egA",
      "role": "owner"
    });

    await gm.deleteGroup(g);
    // no exception should be raised
  });

  test('Delete group (already deleted)', () async {
    final http.Client client = MockClient();
    final AuthModel am = AuthModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final GroupModel gm = GroupModel(am, mocker: client);

    when(client.delete('${GroupModel.GROUP_URL}/2',
            headers: anyNamed("headers")))
        .thenAnswer((_) async => http.Response(
            json.encode(
                <String, dynamic>{"message": "Cannot perform group action"}),
            403));

    // pretend client obtained `g` was from `getGroup` or `getGroups`
    Group g = Group.fromJson(<String, dynamic>{
      "id": 2,
      "name": "foo",
      "createdAt": "2020-01-01T00:00:00.000Z",
      "updatedAt": "2020-01-01T00:00:00.000Z",
      "defaultGroup": false,
      "code": "BG1egA",
      "role": "owner"
    });

    expect(() async => await gm.deleteGroup(g),
        throwsA(isA<ForbiddenRequestException>()));
  });

  test('Join group', () async {
    final http.Client client = MockClient();
    final AuthModel am = AuthModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final GroupModel gm = GroupModel(am, mocker: client);

    when(client.post('${GroupModel.GROUP_URL}/join',
            headers: anyNamed("headers"), body: anyNamed("body")))
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

    final g = await gm.joinGroup(name: "foo");
    expect(g, isA<Group>());
    expect(g.id, 2);
    expect(g.name, "foo");
    expect(g.defaultGroup, false);
    expect(g.code, "BG1egA");
  });

  test('Join group (user already in group)', () async {
    final http.Client client = MockClient();
    final AuthModel am = AuthModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final GroupModel gm = GroupModel(am, mocker: client);

    when(client.post('${GroupModel.GROUP_URL}/join',
            headers: anyNamed("headers"), body: anyNamed("body")))
        .thenAnswer((_) async => http.Response(
            json.encode(
                <String, dynamic>{"message": "Already member of group"}),
            422));

    expect(() async => await gm.joinGroup(name: "foo"),
        throwsA(isA<AlreadyInGroupException>()));
  });

  test('Join group (group not found)', () async {
    final http.Client client = MockClient();
    final AuthModel am = AuthModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final GroupModel gm = GroupModel(am, mocker: client);

    when(client.post('${GroupModel.GROUP_URL}/join',
            headers: anyNamed("headers"), body: anyNamed("body")))
        .thenAnswer((_) async => http.Response(
            json.encode(<String, dynamic>{"message": "Group not found"}), 404));

    expect(() async => await gm.joinGroup(name: "foo"),
        throwsA(isA<GroupNotFoundException>()));
  });

  test('Update group code', () async {
    final http.Client client = MockClient();
    final AuthModel am = AuthModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final GroupModel gm = GroupModel(am, mocker: client);

    when(client.post('${GroupModel.GROUP_URL}/2/code',
            headers: anyNamed("headers")))
        .thenAnswer((_) async => http.Response(
            json.encode(<String, dynamic>{
              "id": 2,
              "name": "foo",
              "defaultGroup": false,
              "code": "5EOoU2",
              "createdAt": "2020-01-01T00:00:00.000Z",
              "updatedAt": "2020-01-01T00:00:00.000Z",
              "role": "owner"
            }),
            200));

    // pretend client obtained `g` was from `getGroup` or `getGroups`
    Group g = Group.fromJson(<String, dynamic>{
      "id": 2,
      "name": "foo",
      "createdAt": "2020-01-01T00:00:00.000Z",
      "updatedAt": "2020-01-01T00:00:00.000Z",
      "defaultGroup": false,
      "code": "BG1egA",
      "role": "owner"
    });

    final updated = await gm.refreshCode(g);
    expect(updated, isA<Group>());
    expect(updated.id, 2);
    expect(updated.name, "foo");
    expect(updated.defaultGroup, false);
    expect(updated.code, "5EOoU2");
  });

  test('Update group code (not allowed or group has been deleted)', () async {
    final http.Client client = MockClient();
    final AuthModel am = AuthModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final GroupModel gm = GroupModel(am, mocker: client);

    when(client.post('${GroupModel.GROUP_URL}/2/code',
            headers: anyNamed("headers")))
        .thenAnswer((_) async => http.Response(
            json.encode(<String, dynamic>{
              "message": "User does not have privilege to access group resource"
            }),
            403));

    // pretend client obtained `g` was from `getGroup` or `getGroups`
    Group g = Group.fromJson(<String, dynamic>{
      "id": 2,
      "name": "foo",
      "createdAt": "2020-01-01T00:00:00.000Z",
      "updatedAt": "2020-01-01T00:00:00.000Z",
      "defaultGroup": false,
      "code": "BG1egA",
      "role": "owner"
    });

    expect(() async => await gm.refreshCode(g),
        throwsA(isA<ForbiddenRequestException>()));
  });

  test('Leave group', () async {
    final http.Client client = MockClient();
    final AuthModel am = AuthModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final GroupModel gm = GroupModel(am, mocker: client);

    when(client.post('${GroupModel.GROUP_URL}/2/leave',
            headers: anyNamed("headers")))
        .thenAnswer((_) async => http.Response("", 204));

    // pretend client obtained `g` was from `getGroup` or `getGroups`
    Group g = Group.fromJson(<String, dynamic>{
      "id": 2,
      "name": "foo",
      "createdAt": "2020-01-01T00:00:00.000Z",
      "updatedAt": "2020-01-01T00:00:00.000Z",
      "defaultGroup": false,
      "code": "BG1egA",
      "role": "owner"
    });

    await gm.leaveGroup(g);
    // no exception should be raised
  });

  test('Leave group (not in group or does not exist)', () async {
    final http.Client client = MockClient();
    final AuthModel am = AuthModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final GroupModel gm = GroupModel(am, mocker: client);

    when(client.post('${GroupModel.GROUP_URL}/2/leave',
            headers: anyNamed("headers")))
        .thenAnswer((_) async => http.Response(
            json.encode(<String, dynamic>{"message": "Cannot leave group"}),
            400));

    // pretend client obtained `g` was from `getGroup` or `getGroups`
    Group g = Group.fromJson(<String, dynamic>{
      "id": 2,
      "name": "foo",
      "createdAt": "2020-01-01T00:00:00.000Z",
      "updatedAt": "2020-01-01T00:00:00.000Z",
      "defaultGroup": false,
      "code": "BG1egA",
      "role": "owner"
    });

    expect(() async => await gm.leaveGroup(g), throwsException);
  });

  test('Kick member', () async {
    final http.Client client = MockClient();
    final AuthModel am = AuthModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final GroupModel gm = GroupModel(am, mocker: client);

    when(client.post('${GroupModel.GROUP_URL}/2/member/kick',
            headers: anyNamed("headers"), body: anyNamed("body")))
        .thenAnswer((_) async => http.Response("", 204));

    // pretend client obtained `g` was from `getGroup` or `getGroups`
    Group g = Group.fromJson(<String, dynamic>{
      "id": 2,
      "name": "foo",
      "createdAt": "2020-01-01T00:00:00.000Z",
      "updatedAt": "2020-01-01T00:00:00.000Z",
      "defaultGroup": false,
      "code": "BG1egA",
      "role": "owner"
    });

    // pretend client obtained `member` from `getMembers`
    User member = User.fromJson(<String, dynamic>{
      "id": 2,
      "updatedAt": "2020-01-01T00:00:00.000Z",
      "name": "Aaron Harwood",
      "role": "member"
    });

    await gm.kickMember(g, member);
    // no exception should be raised
  });

  test('Kick member (not in group)', () async {
    final http.Client client = MockClient();
    final AuthModel am = AuthModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final GroupModel gm = GroupModel(am, mocker: client);

    when(client.post('${GroupModel.GROUP_URL}/2/member/kick',
            headers: anyNamed("headers"), body: anyNamed("body")))
        .thenAnswer((_) async => http.Response(
            json.encode(<String, dynamic>{"message": "Cannot delete member"}),
            400));

    // pretend client obtained `g` was from `getGroup` or `getGroups`
    Group g = Group.fromJson(<String, dynamic>{
      "id": 2,
      "name": "foo",
      "createdAt": "2020-01-01T00:00:00.000Z",
      "updatedAt": "2020-01-01T00:00:00.000Z",
      "defaultGroup": false,
      "code": "BG1egA",
      "role": "owner"
    });

    // pretend client obtained `member` from `getMembers`
    User member = User.fromJson(<String, dynamic>{
      "id": 2,
      "updatedAt": "2020-01-01T00:00:00.000Z",
      "name": "Aaron Harwood",
      "role": "member"
    });

    expect(() async => await gm.kickMember(g, member), throwsException);
  });

  test('Kick member (user not group owner)', () async {
    final http.Client client = MockClient();
    final AuthModel am = AuthModel(
        MainMemKeyValueStore(init: {"token": "asdfqwerty1234567890foobarbaz"}),
        mocker: client);
    final GroupModel gm = GroupModel(am, mocker: client);

    when(client.post('${GroupModel.GROUP_URL}/2/member/kick',
            headers: anyNamed("headers"), body: anyNamed("body")))
        .thenAnswer((_) async => http.Response(
            json.encode(
                <String, dynamic>{"message": "Cannot perform group action"}),
            403));

    // pretend client obtained `g` was from `getGroup` or `getGroups`
    Group g = Group.fromJson(<String, dynamic>{
      "id": 2,
      "name": "foo",
      "createdAt": "2020-01-01T00:00:00.000Z",
      "updatedAt": "2020-01-01T00:00:00.000Z",
      "defaultGroup": false,
      "code": "BG1egA",
      "role": "owner"
    });

    // pretend client obtained `member` from `getMembers`
    User member = User.fromJson(<String, dynamic>{
      "id": 2,
      "updatedAt": "2020-01-01T00:00:00.000Z",
      "name": "Aaron Harwood",
      "role": "member"
    });

    expect(() async => await gm.kickMember(g, member),
        throwsA(isA<ForbiddenRequestException>()));
  });
}

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

import 'package:smart_broccoli/src/remote.dart';
import 'package:smart_broccoli/src/data.dart';

class MockClient extends Mock implements http.Client {}

main() async {
  test('Create group', () async {
    final http.Client client = MockClient();
    final GroupApi api = GroupApi(mocker: client);

    when(client.post(GroupApi.GROUP_URL,
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
            },
            body: isA<String>()))
        .thenAnswer((invocation) async {
      Map<String, dynamic> body =
          json.decode(invocation.namedArguments[Symbol('body')]);

      if (body.containsKey('name'))
        return http.Response(
            json.encode({
              "code": "abc123",
              "id": 10,
              "name": body['name'],
              "defaultGroup": false,
              "updatedAt": "2020-01-01T00:00:00.000Z",
              "createdAt": "2020-01-01T00:00:00.000Z"
            }),
            201);

      return http.Response("", 400);
    });

    final g =
        await api.createGroup("asdfqwerty1234567890foobarbaz", "Lorem ipsum");
    expect(g, isA<Group>());
    expect(g.id, 10);
    expect(g.code, "abc123");
    expect(g.name, "Lorem ipsum");
    expect(g.defaultGroup, false);
    expect(g.members, null);
  });

  test('Create group (name already taken)', () async {
    final http.Client client = MockClient();
    final GroupApi api = GroupApi(mocker: client);

    when(client.post(GroupApi.GROUP_URL,
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
            },
            body: isA<String>()))
        .thenAnswer((invocation) async {
      Map<String, dynamic> body =
          json.decode(invocation.namedArguments[Symbol('body')]);

      if (body.containsKey('name'))
        return http.Response(
            json.encode({
              "message": "Validation error",
              "errors": [
                {
                  "msg": "Uniqueness constraint failure",
                  "location": "body",
                  "param": "name"
                }
              ]
            }),
            409);

      return http.Response("", 400);
    });

    expect(
        () async => await api.createGroup(
            "asdfqwerty1234567890foobarbaz", "Lorem ipsum"),
        throwsA(isA<GroupCreateException>()));
  });

  test('Get groups', () async {
    final http.Client client = MockClient();
    final GroupApi api = GroupApi(mocker: client);

    when(client.get(GroupApi.GROUP_URL, headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
    })).thenAnswer((_) async => http.Response(
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

    final groups = await api.getGroups("asdfqwerty1234567890foobarbaz");
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
    final GroupApi api = GroupApi(mocker: client);

    when(client.get('${GroupApi.GROUP_URL}/2', headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
    })).thenAnswer((_) async => http.Response(
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

    final group = await api.getGroup("asdfqwerty1234567890foobarbaz", 2);
    expect(group, isA<Group>());
    expect(group.id, 2);
    expect(group.name, "foo");
    expect(group.defaultGroup, false);
    expect(group.code, "BG1egA");
  });

  test('Get members of specified group', () async {
    final http.Client client = MockClient();
    final GroupApi api = GroupApi(mocker: client);

    when(client.get('${GroupApi.GROUP_URL}/2/member', headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
    })).thenAnswer((_) async => http.Response(
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

    final members = await api.getMembers("asdfqwerty1234567890foobarbaz", 2);
    expect(members, isA<List<User>>());
    expect(members.length, 3);
    members.sort((t0, t1) => t0.id.compareTo(t1.id));
    expect(members[0].id, 1);
    expect(members[1].id, 2);
    expect(members[2].id, 3);
    expect(members[0].name, "Harald Søndergaard");
    expect(members[1].name, "Aaron Harwood");
    expect(members[2].name, null);
    expect(members[0].groupRole, GroupRole.OWNER);
    expect(members[1].groupRole, GroupRole.MEMBER);
    expect(members[2].groupRole, GroupRole.MEMBER);
  });

  test('Get specified group (does not exist)', () async {
    final http.Client client = MockClient();
    final GroupApi api = GroupApi(mocker: client);

    when(client.get('${GroupApi.GROUP_URL}/44', headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
    })).thenAnswer((_) async => http.Response(
        json.encode(<String, dynamic>{"message": "Group not found"}), 404));

    expect(() async => await api.getGroup("asdfqwerty1234567890foobarbaz", 44),
        throwsA(isA<GroupNotFoundException>()));
  });

  test('Update group', () async {
    final http.Client client = MockClient();
    final GroupApi api = GroupApi(mocker: client);

    when(client.patch('${GroupApi.GROUP_URL}/2',
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
            },
            body: isA<String>()))
        .thenAnswer((invocation) async {
      Map<String, dynamic> body =
          json.decode(invocation.namedArguments[Symbol('body')]);

      if (body.containsKey('name'))
        return http.Response(
            json.encode(<String, dynamic>{
              "id": 2,
              "name": body['name'],
              "createdAt": "2020-01-01T00:00:00.000Z",
              "updatedAt": "2020-01-01T00:00:00.000Z",
              "defaultGroup": false,
              "code": "BG1egA",
              "role": "owner"
            }),
            200);
      return http.Response("", 400);
    });

    final returned =
        await api.updateGroup("asdfqwerty1234567890foobarbaz", 2, "new");
    expect(returned, isA<Group>());
    expect(returned.id, 2);
    expect(returned.name, "new");
    expect(returned.defaultGroup, false);
    expect(returned.code, "BG1egA");
  });

  test('Delete group', () async {
    final http.Client client = MockClient();
    final GroupApi api = GroupApi(mocker: client);

    when(client.delete('${GroupApi.GROUP_URL}/2', headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
    })).thenAnswer((_) async => http.Response("", 204));

    await api.deleteGroup("asdfqwerty1234567890foobarbaz", 2);
  });

  test('Delete group (already deleted)', () async {
    final http.Client client = MockClient();
    final GroupApi api = GroupApi(mocker: client);

    when(client.delete('${GroupApi.GROUP_URL}/2', headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
    })).thenAnswer((_) async => http.Response(
        json.encode(
            <String, dynamic>{"message": "Cannot perform group action"}),
        403));

    expect(
        () async => await api.deleteGroup("asdfqwerty1234567890foobarbaz", 2),
        throwsA(isA<ForbiddenRequestException>()));
  });

  test('Join group', () async {
    final http.Client client = MockClient();
    final GroupApi api = GroupApi(mocker: client);

    when(client.post('${GroupApi.GROUP_URL}/join',
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
            },
            body: isA<String>()))
        .thenAnswer((invocation) async {
      Map<String, dynamic> body =
          json.decode(invocation.namedArguments[Symbol('body')]);

      if (body.containsKey('name'))
        return http.Response(
            json.encode(<String, dynamic>{
              "id": 2,
              "name": body['name'],
              "createdAt": "2020-01-01T00:00:00.000Z",
              "updatedAt": "2020-01-01T00:00:00.000Z",
              "defaultGroup": false,
              "code": "BG1egA",
              "role": "owner"
            }),
            200);

      return http.Response("", 400);
    });

    final g = await api.joinGroup("asdfqwerty1234567890foobarbaz", name: "foo");
    expect(g, isA<Group>());
    expect(g.id, 2);
    expect(g.name, "foo");
    expect(g.defaultGroup, false);
    expect(g.code, "BG1egA");
  });

  test('Join group (user already in group)', () async {
    final http.Client client = MockClient();
    final GroupApi api = GroupApi(mocker: client);

    when(client.post('${GroupApi.GROUP_URL}/join',
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
            },
            body: isA<String>()))
        .thenAnswer((invocation) async {
      Map<String, dynamic> body =
          json.decode(invocation.namedArguments[Symbol('body')]);

      if (body.containsKey('name'))
        return http.Response(
            json.encode(
                <String, dynamic>{"message": "Already member of group"}),
            422);

      return http.Response("", 400);
    });

    expect(
        () async =>
            await api.joinGroup("asdfqwerty1234567890foobarbaz", name: "foo"),
        throwsA(isA<AlreadyInGroupException>()));
  });

  test('Join group (group not found)', () async {
    final http.Client client = MockClient();
    final GroupApi api = GroupApi(mocker: client);

    when(client.post('${GroupApi.GROUP_URL}/join',
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
            },
            body: isA<String>()))
        .thenAnswer((invocation) async {
      Map<String, dynamic> body =
          json.decode(invocation.namedArguments[Symbol('body')]);

      if (body.containsKey('name'))
        return http.Response(
            json.encode(<String, dynamic>{"message": "Group not found"}), 404);

      return http.Response("", 400);
    });

    expect(
        () async =>
            await api.joinGroup("asdfqwerty1234567890foobarbaz", name: "foo"),
        throwsA(isA<GroupNotFoundException>()));
  });

  test('Update group code', () async {
    final http.Client client = MockClient();
    final GroupApi api = GroupApi(mocker: client);

    when(client.post('${GroupApi.GROUP_URL}/2/code', headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
    })).thenAnswer((_) async => http.Response(
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

    final updated = await api.refreshCode("asdfqwerty1234567890foobarbaz", 2);
    expect(updated, isA<Group>());
    expect(updated.id, 2);
    expect(updated.name, "foo");
    expect(updated.defaultGroup, false);
    expect(updated.code, "5EOoU2");
  });

  test('Update group code (not allowed or group has been deleted)', () async {
    final http.Client client = MockClient();
    final GroupApi api = GroupApi(mocker: client);

    when(client.post('${GroupApi.GROUP_URL}/2/code', headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
    })).thenAnswer((_) async => http.Response(
        json.encode(<String, dynamic>{
          "message": "User does not have privilege to access group resource"
        }),
        403));

    expect(
        () async => await api.refreshCode("asdfqwerty1234567890foobarbaz", 2),
        throwsA(isA<ForbiddenRequestException>()));
  });

  test('Leave group', () async {
    final http.Client client = MockClient();
    final GroupApi api = GroupApi(mocker: client);

    when(client.post('${GroupApi.GROUP_URL}/2/leave', headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
    })).thenAnswer((_) async => http.Response("", 204));

    await api.leaveGroup("asdfqwerty1234567890foobarbaz", 2);
  });

  test('Leave group (not in group or does not exist)', () async {
    final http.Client client = MockClient();
    final GroupApi api = GroupApi(mocker: client);

    when(client.post('${GroupApi.GROUP_URL}/2/leave', headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
    })).thenAnswer((_) async => http.Response(
        json.encode(<String, dynamic>{"message": "Cannot leave group"}), 400));

    expect(() async => await api.leaveGroup("asdfqwerty1234567890foobarbaz", 2),
        throwsException);
  });

  test('Kick member', () async {
    final http.Client client = MockClient();
    final GroupApi api = GroupApi(mocker: client);

    when(client.post('${GroupApi.GROUP_URL}/2/member/kick',
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
            },
            body: isA<String>()))
        .thenAnswer((invocation) async {
      Map<String, dynamic> body =
          json.decode(invocation.namedArguments[Symbol('body')]);

      if (body.containsKey('memberId')) return http.Response("", 204);

      return http.Response("", 400);
    });

    await api.kickMember("asdfqwerty1234567890foobarbaz", 2, 3);
  });

  test('Kick member (not in group)', () async {
    final http.Client client = MockClient();
    final GroupApi api = GroupApi(mocker: client);

    when(client.post('${GroupApi.GROUP_URL}/2/member/kick',
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
            },
            body: isA<String>()))
        .thenAnswer((_) async => http.Response(
            json.encode(<String, dynamic>{"message": "Cannot delete member"}),
            400));

    expect(
        () async => await api.kickMember("asdfqwerty1234567890foobarbaz", 2, 3),
        throwsException);
  });

  test('Kick member (user not group owner)', () async {
    final http.Client client = MockClient();
    final GroupApi api = GroupApi(mocker: client);

    when(client.post('${GroupApi.GROUP_URL}/2/member/kick',
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer asdfqwerty1234567890foobarbaz'
            },
            body: isA<String>()))
        .thenAnswer((invocation) async {
      Map<String, dynamic> body =
          json.decode(invocation.namedArguments[Symbol('body')]);

      if (body.containsKey('memberId'))
        return http.Response(
            json.encode(
                <String, dynamic>{"message": "Cannot perform group action"}),
            403);

      return http.Response("", 400);
    });

    expect(
        () async => await api.kickMember("asdfqwerty1234567890foobarbaz", 2, 3),
        throwsA(isA<ForbiddenRequestException>()));
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/local.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/remote.dart';

class MockGroupApi extends Mock implements GroupApi {}

class MockQuizApi extends Mock implements QuizApi {}

class MockPicStash extends Mock implements PictureStash {}

main() async {
  test('Refresh groups', () async {
    final GroupApi api = MockGroupApi();
    final PictureStash ps = MockPicStash();
    final KeyValueStore kv = MainMemKeyValueStore(init: {"token": "abc"});
    final AuthStateModel am = AuthStateModel(kv);
    final UserRepository repo = UserRepository(ps, groupApi: api);
    final QuizCollectionModel qcm = QuizCollectionModel(am, ps);
    final GroupRegistryModel model =
        GroupRegistryModel(am, repo, qcm, groupApi: api);

    when(api.getGroups(any)).thenAnswer(
      (_) async => [
        Group.fromJson(<String, dynamic>{
          "id": 1,
          "name": "Name Here",
          "defaultGroup": true,
          "code": "3hvezW",
          "createdAt": "2020-01-01T00:00:00.000Z",
          "updatedAt": "2020-01-01T00:00:00.000Z",
          "role": "owner"
        }),
        Group.fromJson(<String, dynamic>{
          "id": 2,
          "name": "foo",
          "defaultGroup": false,
          "code": "AzNmrD",
          "createdAt": "2020-01-01T00:00:00.000Z",
          "updatedAt": "2020-01-01T00:00:00.000Z",
          "role": "owner"
        }),
        Group.fromJson(<String, dynamic>{
          "id": 3,
          "name": "bar",
          "defaultGroup": false,
          "code": "QWpmEL",
          "createdAt": "2020-01-01T00:00:00.000Z",
          "updatedAt": "2020-01-01T00:00:00.000Z",
          "role": "member"
        })
      ],
    );

    model.getJoinedGroups();
    model.getCreatedGroups();
    await untilCalled(api.getGroups(any));
    expect(model.joinedGroups, isA<List<Group>>());
    expect(model.createdGroups, isA<List<Group>>());
    expect(model.joinedGroups.length, 1);
    expect(model.createdGroups.length, 2);
  });

  test('Refresh with fetch members', () async {
    final GroupApi api = MockGroupApi();
    final PictureStash ps = MockPicStash();
    final KeyValueStore kv = MainMemKeyValueStore(init: {"token": "abc"});
    final AuthStateModel am = AuthStateModel(kv);
    final UserRepository repo = UserRepository(ps, groupApi: api);
    final QuizCollectionModel qcm = QuizCollectionModel(am, ps);
    final GroupRegistryModel model =
        GroupRegistryModel(am, repo, qcm, groupApi: api);

    when(api.getGroups(any)).thenAnswer(
      (_) async => [
        Group.fromJson(<String, dynamic>{
          "id": 3,
          "name": "bar",
          "defaultGroup": false,
          "code": "QWpmEL",
          "createdAt": "2020-01-01T00:00:00.000Z",
          "updatedAt": "2020-01-01T00:00:00.000Z",
          "role": "member"
        })
      ],
    );

    when(api.getMembers(any, 3)).thenAnswer(
      (_) async => [
        User.fromJson({
          "id": 1,
          "updatedAt": "2020-01-01T00:00:00.000Z",
          "name": "Aaron Harwood",
          "pictureId": null,
          "role": "member"
        }),
        User.fromJson({
          "id": 2,
          "updatedAt": "2020-01-01T00:00:00.000Z",
          "name": "Harald Søndergaard",
          "pictureId": null,
          "role": "owner"
        })
      ],
    );

    await model.getJoinedGroups(withMembers: true);
    expect(model.joinedGroups, isA<List<Group>>());
    expect(model.joinedGroups.length, 1);
    var members = await model.getGroupMembers(3);
    expect(members, isA<List<User>>());
    expect(members.length, 2);
    members.sort((m0, m1) => m0.id.compareTo(m1.id));
    expect(members[0].id, 1);
    expect(members[1].id, 2);
    expect(members[0].name, "Aaron Harwood");
    expect(members[1].name, "Harald Søndergaard");
    expect(members[0].groupRole, GroupRole.MEMBER);
    expect(members[1].groupRole, GroupRole.OWNER);
  });
}

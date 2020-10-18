import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smart_broccoli/cache.dart';
import 'package:smart_broccoli/models.dart';
import 'package:smart_broccoli/src/store/remote/group_api.dart';

class MockGroupApi extends Mock implements GroupApi {}

main() async {
  test('Refresh groups', () async {
    final GroupApi api = MockGroupApi();
    final KeyValueStore kv = MainMemKeyValueStore(init: {"token": "abc"});
    final AuthStateModel am = AuthStateModel(kv);
    final GroupRegistryModel model = GroupRegistryModel(kv, am, groupApi: api);

    when(api.getGroups(any)).thenAnswer(
      (_) => Future.value(
        [
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
      ),
    );

    model.refreshJoinedGroups();
    model.refreshCreatedGroups();
    await untilCalled(api.getGroups(any));
    expect(model.joinedGroups, isA<List<Group>>());
    expect(model.createdGroups, isA<List<Group>>());
    expect(model.joinedGroups.length, 1);
    expect(model.createdGroups.length, 2);
  });
}

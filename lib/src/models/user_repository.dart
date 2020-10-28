import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/local.dart';
import 'package:smart_broccoli/src/remote.dart';

/// Cached provider of user profiles and profile pictures
/// Delegates to the user API if the resource is not in the cache.
class UserRepository {
  /// API provider for the user profile service
  UserApi _userApi;

  /// API provider for the group management service
  GroupApi _groupApi;

  /// Picture storage service
  final PictureStash _picStash;

  Map<int, User> _users = {};

  UserRepository(this._picStash, {UserApi userApi, GroupApi groupApi}) {
    _userApi = userApi ?? UserApi();
    _groupApi = groupApi ?? GroupApi();
  }

  Future<String> getUserPicture(int id) {
    if (_users[id]?.pictureId == null) return null;
    return _picStash.getPic(_users[id].pictureId);
  }

  Future<User> getUserBy(String token, int id, {bool fromCache = true}) async {
    // first try from cache
    if (fromCache && _users.containsKey(id)) return _users[id];
    // if not found (or caller specified not from cache), use the API
    _users[id] = await _userApi.getUserBy(token, id);
    // If user has picture and picture is not stored in cache
    if (_users[id].pictureId != null &&
        await _picStash.getPic(_users[id].pictureId) == null) {
      var picture = await _userApi.getProfilePicOf(token, id);
      await _picStash.storePic(_users[id].pictureId, picture);
    }
    return _users[id];
  }

  Future<User> updateUser(String token,
          {String email, String password, String name}) async =>
      await _userApi.updateUser(token,
          email: email, password: password, name: name);

  Future<List<User>> getMembersOf(String token, int id) async {
    List<User> members = await _groupApi.getMembers(token, id);
    await Future.wait(members.map((member) async {
      // store member in the hashmap
      _users[member.id] = member;
      // If user has picture and picture is not stored in cache
      if (member.pictureId != null &&
          await _picStash.getPic(member.pictureId) == null) {
        var picture = await _userApi.getProfilePicOf(token, member.id);
        await _picStash.storePic(member.pictureId, picture);
      }
    }));
    return members;
  }
}

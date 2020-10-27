import 'dart:typed_data';

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

  Future<User> getUser(String token) async {
    User user = await _userApi.getUser(token);
    // no picture; return straight away
    if (user.pictureId == null) return user;
    // otherwise, check whether picture has already been cached
    if ((user.picture = await _picStash.getPic(user.pictureId)) != null)
      return user;
    // if not, use the API then cache the picture (in background) for next time
    var picture = await _userApi.getProfilePic(token);
    user.picture = await _picStash.storePic(user.pictureId, picture);
    return user;
  }

  Future<User> getUserBy(String token, int id, {bool fromCache = true}) async {
    // first try from cache
    if (fromCache && _users.containsKey(id)) return _users[id];
    // if not found (or caller specified not from cache), use the API
    _users[id] = await _userApi.getUserBy(token, id);
    // no picture; return straight away
    if (_users[id].pictureId == null) return _users[id];
    // otherwise, check whether picture has already been cached
    if ((_users[id].picture = await _picStash.getPic(_users[id].pictureId)) !=
        null) return _users[id];
    // if not, use the API then cache the picture (in background) for next time
    var picture = await _userApi.getProfilePic(token);
    _users[id].picture =
        await _picStash.storePic(_users[id].pictureId, picture);
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
      // and look for profile pic locally before falling back to API
      if (member.pictureId != null &&
          (member.picture = await _picStash.getPic(member.pictureId)) == null) {
        try {
          var picture = await _userApi.getProfilePicOf(token, member.id);
          member.picture = await _picStash.storePic(member.pictureId, picture);
        } catch (_) {
          // if unable to get the profie pic from the API, simply move on
        }
      }
    }));
    return members;
  }
}

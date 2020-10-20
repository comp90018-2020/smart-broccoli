import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

import 'package:smart_broccoli/src/remote.dart';
import 'package:smart_broccoli/src/data.dart';

/// Cached provider of user profiles and profile pictures
/// Delegates to the user API if the resource is not in the cache.
class UserRepository {
  /// API provider for the user profile service
  UserApi _userApi;

  /// API provider for the group management service
  GroupApi _groupApi;

  Map<int, User> _users = {};

  UserRepository({UserApi userApi, GroupApi groupApi}) {
    _userApi = userApi ?? UserApi();
    _groupApi = groupApi ?? GroupApi();
  }

  Future<User> getUser(String token) async {
    User user = await _userApi.getUser(token);
    // no picture; return straight away
    if (user.pictureId == null) return user;
    // otherwise, check whether picture has already been cached
    if ((user.picture = await lookupPicLocally(user.pictureId)) != null)
      return user;
    // if not, use the API then cache the picture (in background) for next time
    user.picture = await _userApi.getProfilePic(token);
    _storePicLocally(user.pictureId, user.picture); // no need to await
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
    if ((_users[id].picture = await lookupPicLocally(_users[id].pictureId)) !=
        null) return _users[id];
    // if not, use the API then cache the picture (in background) for next time
    _users[id].picture = await _userApi.getProfilePic(token);
    _storePicLocally(
        _users[id].pictureId, _users[id].picture); // no need to await
    return _users[id];
  }

  Future<User> updateUser(String token,
          {String email, String password, String name}) async =>
      await _userApi.updateUser(token,
          email: email, password: password, name: name);

  Future<List<User>> getMembersOf(String token, int id) async {
    List<User> members = await _groupApi.getMembers(token, id);
    members.forEach((member) async {
      _users[member.id] = member;
      // store member in the hashmap and look for profile pic locally first
      if (member.pictureId != null &&
          (member.picture = await lookupPicLocally(member.pictureId)) == null)
        member.picture = await _userApi.getProfilePic(token);
    });
    return members;
  }

  Future<Uint8List> getProfilePicOf(String token, int id) async {
    Uint8List bytes;
    if (_users.containsKey(id) &&
        (bytes = await lookupPicLocally(_users[id].pictureId)) != null)
      return bytes;
    return await _userApi.getProfilePicOf(token, id);
  }

  Future<Uint8List> lookupPicLocally(int pictureId) async {
    String assetDir =
        '${(await getTemporaryDirectory()).toString()}/picture/$pictureId';
    try {
      // see if the image is already stored locally
      return File(assetDir).readAsBytes();
    } catch (_) {
      return null;
    }
  }

  Future<void> _storePicLocally(int pictureId, Uint8List bytes) async {
    String assetDir =
        '${(await getTemporaryDirectory()).toString()}/picture/$pictureId';
    try {
      File f = File(assetDir);
      f.writeAsBytes(bytes);
    } catch (_) {}
  }
}

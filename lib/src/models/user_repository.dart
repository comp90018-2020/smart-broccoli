import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:smart_broccoli/models.dart';

import '../store/remote/user_api.dart';

/// Cached provider of user profiles and profile pictures
/// Delegates to the user API if the resource is not in the cache.
class UserRepository {
  /// API provider for the user profile service
  UserApi _userApi;

  Map<int, User> _users;

  UserRepository({UserApi userApi}) {
    _userApi = userApi ?? UserApi();
  }

  Future<User> getUserBy(String token, int id, {bool fromCache = true}) async {
    // first try from cache
    if (fromCache && _users.containsKey(id)) return _users[id];
    // otherwise, get from API
    _users[id] = await _userApi.getUserBy(token, id);
    // in the background (no await), fetch profile pic
    getProfilePicOf(token, id);
    return _users[id];
  }

  Future<Uint8List> getProfilePicOf(String token, int id) async {
    // TODO: store imgId in User object and use to check cache
    String assetDir =
        '${(await getTemporaryDirectory()).toString()}/picture/$id';
    try {
      // see if the image is already stored locally
      return File(assetDir).readAsBytes();
    } catch (_) {
      // if not, use the API
      Uint8List bytes = await _userApi.getProfilePicOf(token, id);
      if (bytes == null) return null;
      File f = File(assetDir);
      f.writeAsBytes(bytes);
      return bytes;
    }
  }
}

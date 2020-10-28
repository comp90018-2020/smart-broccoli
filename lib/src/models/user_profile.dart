import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/local.dart';
import 'package:smart_broccoli/src/remote.dart';
import 'model_change.dart';

import 'auth_state.dart';

/// View model for the user's profile
class UserProfileModel extends ChangeNotifier implements AuthChange {
  /// AuthStateModel object used to obtain token for requests
  final AuthStateModel _authStateModel;

  /// Local storage service
  KeyValueStore _keyValueStore;

  /// Picture storage service
  final PictureStash _picStash;

  UserApi _userApi;

  /// Views subscribe to the fields below
  User _user;
  User get user => _user;

  /// Constructor for external use
  UserProfileModel(this._keyValueStore, this._authStateModel, this._picStash,
      {UserApi userApi}) {
    _userApi = userApi ?? UserApi();
    // load last record of profile and picture
    var userJson = _keyValueStore.getString('user');
    if (userJson != null) {
      _user = User.fromJson(json.decode(userJson));
    }
  }

  /// Function to get user
  Future<User> getUser({bool forceRefresh = false}) async {
    // If in cache and we don't force refresh
    if (!forceRefresh && user != null) {
      return user;
    }
    // If not, retrieve user
    return await _refreshUser();
  }

  /// Retrieve user picture from cache
  Future<String> getUserPicture({bool forceRefresh = false}) async {
    if (user?.pictureId == null) return null;
    return await _picStash.getPic(user.pictureId);
  }

  /// Retrieve user and image from API
  Future<User> _refreshUser() async {
    if (!_authStateModel.inSession) return null;
    _user = await _userApi.getUser(_authStateModel.token);
    _keyValueStore.setString('user', json.encode(_user.toJson()));
    // If user has picture and picture is not stored in cache
    if (_user.pictureId != null &&
        await _picStash.getPic(_user.pictureId) == null) {
      var picture = await _userApi.getProfilePic(_authStateModel.token);
      await _picStash.storePic(user.pictureId, picture);
    }
    notifyListeners();
    return _user;
  }

  Future<void> updateUser({String email, String password, String name}) async {
    if (!_authStateModel.inSession) return null;
    _user = await _userApi.updateUser(_authStateModel.token,
        email: email, password: password, name: name);
    _keyValueStore.setString('user', json.encode(_user.toJson()));
    notifyListeners();
  }

  Future<void> updateProfilePic(Uint8List bytes) async {
    if (!_authStateModel.inSession) return null;
    await _userApi.setProfilePic(_authStateModel.token, bytes);
    _refreshUser();
  }

  Future<void> promoteUser(String email, String password, String name) async {
    if (!_authStateModel.inSession) return null;
    await _authStateModel.promote(email, password, name);
    _refreshUser();
  }

  /// When the auth state is updated
  void authUpdated() {
    if (!_authStateModel.inSession) {
      this._user = null;
      this._picStash.clear();
    }
  }
}

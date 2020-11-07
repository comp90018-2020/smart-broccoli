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
  Future<User> getUser({bool refresh = false}) async {
    // If in cache and we don't force refresh
    if (!refresh && user != null) {
      return user;
    }
    // If not, retrieve user
    return _refreshUser();
  }

  /// Retrieve user picture from cache
  Future<String> getUserPicture() async {
    if (user?.pictureId == null) return null;
    return await _picStash.getPic(user.pictureId);
  }

  /// Retrieve user and image from API
  Future<User> _refreshUser() async {
    if (!_authStateModel.inSession) return null;

    try {
      _user = await _userApi.getUser(_authStateModel.token);
      _keyValueStore.setString('user', json.encode(_user.toJson()));
    } on ApiAuthException {
      _authStateModel.checkSession();
    } on ApiException catch (e) {
      return Future.error(e.toString());
    } on Exception {
      return Future.error("Something went wrong");
    }

    // If user has picture and picture is not stored in cache
    if (_user.pictureId != null &&
        await _picStash.getPic(_user.pictureId) == null) {
      try {
        var picture = await _userApi.getProfilePic(_authStateModel.token);
        await _picStash.storePic(user.pictureId, picture);
      } on ApiAuthException {
        _authStateModel.checkSession();
      } on Exception {
        // Ignore
      }
    }

    notifyListeners();
    return _user;
  }

  /// Updates user profile information
  Future<void> updateUser({String email, String password, String name}) async {
    if (!_authStateModel.inSession) return null;

    try {
      _user = await _userApi.updateUser(_authStateModel.token,
          email: email, password: password, name: name);
      _keyValueStore.setString('user', json.encode(_user.toJson()));
      notifyListeners();
    } on ApiAuthException {
      await _authStateModel.checkSession();
    } on ApiException catch (e) {
      return Future.error(e.toString());
    } on Exception {
      return Future.error("Something went wrong");
    }
  }

  /// Updates user's profile picture
  Future<void> updateProfilePic(Uint8List bytes) async {
    if (!_authStateModel.inSession) return null;

    try {
      await _userApi.setProfilePic(_authStateModel.token, bytes);
    } on ApiAuthException {
      await _authStateModel.checkSession();
    } on ApiException catch (e) {
      return Future.error(e.toString());
    } on Exception {
      return Future.error("Something went wrong");
    }

    _refreshUser();
  }

  /// Promotes user from joined to registered
  Future<void> promoteUser(String email, String password, String name) async {
    if (!_authStateModel.inSession) return null;

    try {
      await _authStateModel.promote(email, password, name);
    } on ApiAuthException {
      await _authStateModel.checkSession();
    } on ApiException catch (e) {
      return Future.error(e.toString());
    } on Exception {
      return Future.error("Something went wrong");
    }

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

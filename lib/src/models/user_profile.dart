import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/local.dart';
import 'package:smart_broccoli/src/remote.dart';

import 'auth_state.dart';
import 'user_repository.dart';

/// View model for the user's profile
class UserProfileModel extends ChangeNotifier {
  /// AuthStateModel object used to obtain token for requests
  final AuthStateModel _authStateModel;

  /// Cached provider for user profile service
  UserRepository _userRepo;

  /// Local storage service
  KeyValueStore _keyValueStore;

  /// Picture storage service
  final PictureStash _picStash;

  UserApi _userApi;

  /// Views subscribe to the fields below
  User _user;
  User get user => _user;

  /// Constructor for external use
  UserProfileModel(
      this._keyValueStore, this._authStateModel, this._userRepo, this._picStash,
      {UserApi userApi}) {
    _userApi = userApi ?? UserApi();
    // load last record of profile and picture
    try {
      _user = User.fromJson(json.decode(_keyValueStore.getString('user')));
      if (_user?.pictureId != null) _picStash.getPic(_user.pictureId);
    } catch (_) {}
  }

  Future<void> refreshUser() async {
    _user = await _userRepo.getUser(_authStateModel.token);
    _keyValueStore.setString('user', json.encode(_user.toJson()));
    notifyListeners();
  }

  Future<void> updateUser({String email, String password, String name}) async {
    _user = await _userRepo.updateUser(_authStateModel.token,
        email: email, password: password, name: name);
    _keyValueStore.setString('user', json.encode(_user.toJson()));
    notifyListeners();
  }

  Future<void> updateProfilePic(Uint8List bytes) async {
    await _userApi.setProfilePic(_authStateModel.token, bytes);
    refreshUser();
  }
}

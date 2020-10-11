import 'dart:typed_data';

import 'package:flutter/cupertino.dart';

import '../data/user.dart';
import '../store/local/key_value.dart';
import '../store/remote/user_api.dart';
import 'auth.dart';

/// View model for the user's profile
class UserProfileModel extends ChangeNotifier {
  /// AuthModel object used to obtain token for requests
  final AuthStateModel _authStateModel;

  UserApi _userApi;

  User _user;
  User get user => _user;

  Uint8List _profileImage;

  KeyValueStore _keyValueStore;

  /// Constructor for external use
  UserProfileModel(this._keyValueStore, this._authStateModel, {UserApi userApi}) {
    _userApi = userApi ?? UserApi();
    _user = User.fromJson(_keyValueStore.getItem('user'));
    // TODO: load image
  }

  Future<void> refreshUser() async {
    User user = await _userApi.getUser(_authStateModel.token);
    _user = user;
    _keyValueStore.setItem('user', user);
    notifyListeners();
  }

  // TODO
  Future<void> updateUser({String email, String password, String name}) {}

  Future<void> getImage() async {
    Uint8List image = await _userApi.getProfilePic(_authStateModel.token);
    _profileImage = image;
    // TODO: save to disk
  }
}

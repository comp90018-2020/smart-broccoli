import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';

import '../data/user.dart';
import '../store/local/key_value.dart';
import '../store/remote/user_api.dart';
import 'auth.dart';

/// View model for the user's profile
class UserProfileModel extends ChangeNotifier {
  /// AuthStateModel object used to obtain token for requests
  final AuthStateModel _authStateModel;

  /// API provider for the user profile service
  UserApi _userApi;

  /// Local storage service
  KeyValueStore _keyValueStore;

  /// Views subscribe to the fields below
  User _user;
  User get user => _user;
  Uint8List _profileImage;
  Uint8List get profileImage => _profileImage;

  /// Constructor for external use
  UserProfileModel(this._keyValueStore, this._authStateModel,
      {UserApi userApi}) {
    _userApi = userApi ?? UserApi();
    _user = User.fromJson(json.decode(_keyValueStore.getString('user')));
    _profileImage = json.decode(_keyValueStore.getString('profilePic'));
  }

  Future<void> refreshUser() async {
    _user = await _userApi.getUser(_authStateModel.token);;
    _keyValueStore.setString('user', json.encode(_user.toJson()));
    notifyListeners();
  }

  Future<void> updateUser({String email, String password, String name}) async {
    _user = await _userApi.updateUser(_authStateModel.token,
        email: email, password: password, name: name);
    _keyValueStore.setString('user', json.encode(_user.toJson()));
    notifyListeners();
  }

  Future<void> getImage() async {
    _profileImage = await _userApi.getProfilePic(_authStateModel.token);
    _keyValueStore.setString('profilePic', utf8.decode(_profileImage));
    notifyListeners();
  }
}

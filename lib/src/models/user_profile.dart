import 'dart:convert';
import 'package:flutter/widgets.dart';

import 'auth_state.dart';
import 'user_repository.dart';
import '../data/user.dart';
import '../store/local/key_value.dart';

/// View model for the user's profile
class UserProfileModel extends ChangeNotifier {
  /// AuthStateModel object used to obtain token for requests
  final AuthStateModel _authStateModel;

  /// Cached provider for user profile service
  UserRepository _userRepo;

  /// Local storage service
  KeyValueStore _keyValueStore;

  /// Views subscribe to the fields below
  User _user;
  User get user => _user;

  /// Constructor for external use
  UserProfileModel(this._keyValueStore, this._authStateModel, this._userRepo) {
    // load last record of profile and picture
    try {
      _user = User.fromJson(json.decode(_keyValueStore.getString('user')));
      if (_user?.pictureId != null) _userRepo.lookupPicLocally(_user.pictureId);
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
}

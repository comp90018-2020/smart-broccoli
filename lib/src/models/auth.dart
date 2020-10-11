import 'package:flutter/material.dart';
import 'package:smart_broccoli/cache.dart';

import '../store/remote/auth_api.dart';

/// View model for the authentication state of the user
class AuthStateModel extends ChangeNotifier {
  /// Object implementing the KeyValueStore interface for local caching
  final KeyValueStore _keyValueStore;

  /// Token used for the authorization header where required
  String _token;
  String get token {
    return _token;
  }

  /// API provider for the auth service
  AuthApi _authApi;

  /// Constructor for external use
  AuthStateModel(this._keyValueStore, {AuthApi authApi}) {
    _token = _keyValueStore.getItem('token');
    _authApi = authApi ?? AuthApi();
  }

  /// Return `true` if the user has logged in or joined as a participant.
  /// Caveat: The token may be revoked; this method only checks that the user
  /// has previously logged in/joined without subsequently logging out.
  /// To validate the session, use `checkSession`.
  bool get inSession {
    return _token != null;
  }

  Future<void> join() async {
    String token = await _authApi.join();
    this._token = token;
    await _keyValueStore.setItem('token', token);
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    String token = await _authApi.login(email, password);
    this._token = token;
    await _keyValueStore.setItem('token', token);
    notifyListeners();
  }

  Future<void> checkSession() async {
    if (token == null || await _authApi.sessionIsValid(_token)) return;
    _token = null;
    await _keyValueStore.clear();
    notifyListeners();
  }

  Future<void> logout() async {
    await _authApi.logout(_token);
    await _keyValueStore.clear();
    notifyListeners();
  }
}

import 'package:flutter/widgets.dart';

import 'package:smart_broccoli/src/local.dart';
import 'package:smart_broccoli/src/remote.dart';

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

  /// Views subscribe to this field
  /// `true` if the user has logged in or joined as a participant.
  /// Caveat: The token may be revoked; this method only checks that the user
  /// has previously logged in/joined without subsequently logging out.
  /// To validate the session, use `checkSession`.
  bool get inSession => _token != null;

  /// Constructor for external use
  AuthStateModel(this._keyValueStore, {AuthApi authApi}) {
    _token = _keyValueStore.getString('token');
    _authApi = authApi ?? AuthApi();
  }

  Future<void> join() async {
    String token = await _authApi.join();
    this._token = token;
    await _keyValueStore.setString('token', token);
    notifyListeners();
  }

  Future<void> register(String email, String password, String name) async {
    await _authApi.register(email, password, name);
  }

  Future<void> promote(String email, String password, String name) async {
    await _authApi.promote(_token, email, password, name);
  }

  Future<void> login(String email, String password) async {
    String token = await _authApi.login(email, password);
    this._token = token;
    await _keyValueStore.setString('token', token);
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
    _token = null;
    await _keyValueStore.clear();
    notifyListeners();
  }
}

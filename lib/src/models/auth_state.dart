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
    try {
      String token = await _authApi.join();
      this._token = token;
      await _keyValueStore.setString('token', token);
      notifyListeners();
    } on ApiException catch (e) {
      return Future.error(e.toString());
    } on Exception {
      return Future.error("Something went wrong");
    }
  }

  Future<void> register(String email, String password, String name) async {
    try {
      await _authApi.register(email, password, name);
    } on ApiException catch (e) {
      return Future.error(e.toString());
    } on Exception {
      return Future.error("Something went wrong");
    }
  }

  Future<void> promote(String email, String password, String name) async {
    await _authApi.promote(_token, email, password, name);
  }

  /// Handles user login, caches token locally
  Future<void> login(String email, String password) async {
    try {
      String token = await _authApi.login(email, password);
      this._token = token;
      await _keyValueStore.setString('token', token);
      notifyListeners();
    } on ApiException catch (e) {
      return Future.error(e.toString());
    } on Exception {
      return Future.error("Something went wrong");
    }
  }

  Future<void> checkSession() async {
    // No token in the first place
    if (token == null) return;

    try {
      // No problems
      if (await _authApi.sessionIsValid(_token)) return;
    } catch (_) {
      // Likely network error
      return;
    }

    // Session no longer value
    _token = null;
    await _keyValueStore.clear();
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await _authApi.logout(_token);
    } catch (_) {
      // Avoid to be stuck when the server is down
    }

    _token = null;
    await _keyValueStore.clear();
    notifyListeners();
  }
}

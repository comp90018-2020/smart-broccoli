import 'package:smart_broccoli/cache.dart';
import 'package:smart_broccoli/src/store/remote/auth_api.dart';

/// Class for making auth requests
class AuthStateModel {
  /// Object implementing the KeyValueStore interface for local caching
  final KeyValueStore _keyValueStore;

  /// Token used for the authorization header where required
  String _token;
  String get token {
    return _token;
  }

  AuthApi _authApi;

  /// Constructor for external use
  AuthStateModel(this._keyValueStore, {AuthApi authApi}) {
    _token = _keyValueStore.getString('token');
    _authApi = authApi ?? AuthApi();
  }

  /// Return `true` if the user has logged in or joined as a participant.
  /// Caveat: The token may be revoked; this method only checks that the user
  /// has previously logged in/joined without subsequently logging out.
  /// To validate the session, use `sessionIsValid`.
  bool inSession() {
    return _token != null;
  }

  Future<void> join() async {
    String token = await _authApi.join();
    this._token = token;
    await _keyValueStore.setString('token', token);
  }

  Future<void> login(String email, String password) async {
    String token = await _authApi.login(email, password);
    this._token = token;
    await _keyValueStore.setString('token', token);
  }

  Future<void> sessionIsValid() async {
    bool valid = await _authApi.sessionIsValid(_token);
    if (!valid) {
      _token = null;
      await _keyValueStore.clear();
    }
  }

  Future<void> logout() async {
    bool _ = await _authApi.logout(_token);
    await _keyValueStore.clear();
  }
}

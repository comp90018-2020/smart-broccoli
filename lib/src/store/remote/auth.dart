import 'dart:convert';

import 'package:fuzzy_broccoli/cache.dart';
import 'package:fuzzy_broccoli/models.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import 'api_base.dart';

/// Class for making auth requests
class AuthModel {
  static const AUTH_URL = ApiBase.BASE_URL + '/auth';

  /// Object implementing the KeyValueStore interface for local caching
  final KeyValueStore _keyValueStore;

  /// HTTP client (mock client can be specified for testing)
  http.Client _http;

  /// Token used for the authorization header where required
  String _token;
  String get token {
    return _token;
  }

  /// Constructor for external use
  AuthModel(this._keyValueStore, {http.Client mocker}) {
    _token = _keyValueStore.getString('token');
    _http = mocker != null ? mocker : IOClient();
  }

  /// Return `true` if the user has logged in or joined as a participant.
  /// Caveat: The token may be revoked; this method only checks that the user
  /// has previously logged in/joined without subsequently logging out.
  /// To validate the session, use `sessionIsValid`.
  bool inSession() {
    return _token != null;
  }

  /// Join as an unregistered (i.e. participant, student) user.
  /// `ParticipantJoinException` is thrown if the server cannot fulfil the
  /// participant join.
  Future<void> join() async {
    final http.Response res =
        await _http.post('$AUTH_URL/join', headers: ApiBase.headers());

    if (res.statusCode != 200) throw ParticipantJoinException();

    String token = json.decode(res.body)['token'];
    this._token = token;
    _keyValueStore.setString('token', token);
  }

  /// Register a user with login details.
  /// `RegistrationConflictException` is thrown if the email is already in use.
  /// `RegistrationException` is thrown if the user cannot be registered due to
  /// a different reason.
  Future<RegisteredUser> register(
      String email, String password, String name) async {
    final http.Response res = await _http.post('$AUTH_URL/register',
        headers: ApiBase.headers(),
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
          'name': name,
        }));

    if (res.statusCode == 201)
      return RegisteredUser.fromJson(json.decode(res.body));
    else if (res.statusCode == 409)
      throw RegistrationConflictException();
    else
      throw RegistrationException();
  }

  /// Promote a participant user to a registered user.
  /// `RegistrationConflictException` is thrown if the email is already in use.
  /// `ParticipantPromotionException` is thrown if the user cannot be registered
  /// due to a different reason.
  Future<RegisteredUser> promote(
      String email, String password, String name) async {
    final http.Response res = await _http.post('$AUTH_URL/promote',
        headers: ApiBase.headers(),
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
          'name': name,
        }));

    if (res.statusCode == 200)
      return RegisteredUser.fromJson(json.decode(res.body));
    else if (res.statusCode == 409)
      throw RegistrationConflictException();
    else
      throw ParticipantPromotionException();
  }

  /// Authenticate a registered user.
  /// `LoginFailedException` is thrown if the login is unsuccessful.
  Future<void> login(String email, String password) async {
    final http.Response res = await _http.post('$AUTH_URL/login',
        headers: ApiBase.headers(),
        body:
            jsonEncode(<String, String>{'email': email, 'password': password}));

    if (res.statusCode != 200) throw LoginFailedException();

    _token = json.decode(res.body)['token'];
    _keyValueStore.setString('token', _token);
  }

  /// Validate the session with the server.
  /// Return `true` if the token is valid and unrevoked.
  Future<bool> sessionIsValid() async {
    if (token == null) return false;
    final http.Response res = await _http.get('$AUTH_URL/session',
        headers: ApiBase.headers(authToken: token));
    if (res.statusCode == 200) return true;
    _token = null;
    return false;
  }

  /// Invalidate the session.
  /// Clear the cache and request the server to revoke the token.
  /// Return `true` if successful.
  Future<bool> logout() async {
    final http.Response res = await _http.post(AUTH_URL + '/logout',
        headers: ApiBase.headers(authToken: token));
    if (res.statusCode == 200) {
      _token = null;
      _keyValueStore.clear();
      return true;
    }
    return false;
  }
}

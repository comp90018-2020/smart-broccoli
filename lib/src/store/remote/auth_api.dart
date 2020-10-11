import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:smart_broccoli/models.dart';

import 'api_base.dart';

class AuthApi {
  static const AUTH_URL = ApiBase.BASE_URL + '/auth';

  /// HTTP client (mock client can be specified for testing)
  http.Client _http;

  AuthApi({http.Client mocker}) {
    _http = mocker ?? IOClient();
  }

  /// Join as an unregistered (i.e. participant, student) user.
  /// `ParticipantJoinException` is thrown if the server cannot fulfil the
  /// participant join.
  Future<String> join() async {
    final http.Response res =
        await _http.post('$AUTH_URL/join', headers: ApiBase.headers());

    if (res.statusCode != 200) throw ParticipantJoinException();

    return json.decode(res.body)['token'];
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
  Future<String> login(String email, String password) async {
    final http.Response res = await _http.post('$AUTH_URL/login',
        headers: ApiBase.headers(),
        body:
            jsonEncode(<String, String>{'email': email, 'password': password}));

    if (res.statusCode != 200) throw LoginFailedException();

    return json.decode(res.body)['token'];
  }

  /// Validate the session with the server.
  /// Return `true` if the token is valid and unrevoked.
  Future<bool> sessionIsValid(String token) async {
    if (token == null) return false;
    final http.Response res = await _http.get('$AUTH_URL/session',
        headers: ApiBase.headers(authToken: token));
    if (res.statusCode == 200) return true;
    return false;
  }

  /// Invalidate the session.
  /// Clear the cache and request the server to revoke the token.
  /// Return `true` if successful.
  Future<bool> logout(String token) async {
    final http.Response res = await _http.post(AUTH_URL + '/logout',
        headers: ApiBase.headers(authToken: token));
    if (res.statusCode == 200) {
      return true;
    }
    return false;
  }
}

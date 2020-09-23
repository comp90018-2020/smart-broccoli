import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/user.dart';
import 'api_base.dart';
import 'key_value.dart';

/// Singleton class for making requests requiring authorisation
class AuthModel {
  static const AUTH_URL = ApiBase.BASE_URL + '/auth';

  KeyValueStore _keyValueStore;

  String _token = '';
  String get token {
    return _token;
  }

  /// Constructor for internal use only
  AuthModel(this._keyValueStore) {
    _token = _keyValueStore.getString('token');
  }

  bool inSession() {
    return _token != null;
  }

  Future<bool> join() async {
    final http.Response res =
        await http.post('$AUTH_URL/join', headers: ApiBase.headers());

    if (res.statusCode == 200) {
      String token = json.decode(res.body)['token'];
      this._token = token;
      _keyValueStore.setString('token', token);
      return true;
    } else {
      return null;
    }
  }

  Future<RegisteredUser> register(
      String email, String password, String name) async {
    final http.Response res = await http.post('$AUTH_URL/register',
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

  Future<bool> login(String email, String password) async {
    final http.Response res = await http.post('$AUTH_URL/login',
        headers: ApiBase.headers(),
        body:
            jsonEncode(<String, String>{'email': email, 'password': password}));

    if (res.statusCode == 200) {
      String token = json.decode(res.body)['token'];
      _keyValueStore.setString('token', token);
      return true;
    } else {
      // todo
      return null;
    }
  }

  Future<bool> sessionIsValid() async {
    final http.Response res =
        await http.get('/session', headers: ApiBase.headers(authToken: token));
    return res.statusCode == 200;
  }

  Future<bool> logout() async {
    final http.Response res = await http.post(AUTH_URL + '/logout',
        headers: ApiBase.headers(authToken: token));
    if (res.statusCode == 200) {
      _token = '';
      _keyValueStore.clear();
      return true;
    }
    return false;
  }
}

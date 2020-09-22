import 'package:injectable/injectable.dart';
import '../models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './api_base.dart';

/// Singleton class for making requests requiring authorisation
@singleton
class AuthService {
  static const AUTH_URL = ApiBase.BASE_URL + '/auth';

  String _token = '';
  String get token {
    return _token;
  }

  AuthService(this._token);

  @factoryMethod
  static Future<AuthService> create() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token");
    return AuthService(token);
  }

  Future<RegisteredUser> register(
      String email, String password, String name) async {
    // send request
    final http.Response res = await http.post("$AUTH_URL/register",
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
          'name': name,
        }));

    if (res.statusCode == 201) {
      return RegisteredUser.fromJson(json.decode(res.body));
    } else if (res.statusCode == 409) {
      // todo: specify which registration params are causing conflict
      throw RegistrationConflictException(List());
    } else {
      throw RegistrationException();
    }
  }

  Future<bool> login(String email, String password) async {
    final http.Response res = await http.post("$AUTH_URL/login",
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body:
            jsonEncode(<String, String>{'email': email, 'password': password}));

    if (res.statusCode == 200) {
      String token = json.decode(res.body)['token'];
      final prefs = await SharedPreferences.getInstance();
      prefs.setString("token", token);
      return true;
    } else {
      // todo
      return null;
    }
  }

  Future<bool> sessionIsValid() async {
    final http.Response res = await ApiBase.get("/session", authToken: token);
    return res.statusCode == 200;
  }

  Future<bool> logout() async {
    final http.Response res =
        await ApiBase.post(AUTH_URL + "/logout", authToken: token);
    if (res.statusCode == 200) {
      _token = '';
      return true;
    }
    return false;
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

part 'auth.g.dart';

const AUTH_URL = 'http://fuzzybroccoli.com/auth';

/// Singleton class for making requests requiring authorisation
@JsonSerializable()
class AuthenticatedRequestHandler {
  static AuthenticatedRequestHandler _instance;

  AuthToken token;
  Role role;

  static Future<AuthenticatedRequestHandler> getInstance() async {
    if (_instance != null) return _instance;

    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('AuthenticatedRequestHandler'))
      return AuthenticatedRequestHandler(null, null);

    return AuthenticatedRequestHandler.fromJson(
        json.decode(prefs.getString('AuthenticatedRequestHandler')));
  }

  Future<void> serialise() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('AuthenticatedRequestHandler', json.encode(this.toJson()));
  }

  Future<bool> sessionIsValid() async {
    final http.Response res =
        await http.post(AUTH_URL + "/session", headers: _headers);
    if (res.statusCode == 200) return true;
    return false;
  }

  Future<bool> logout() async {
    final http.Response res =
        await http.post(AUTH_URL + "/logout", headers: _headers);
    if (res.statusCode == 200) {
      token = null;
      role = null;
      return true;
    }
    return false;
  }

  AuthenticatedRequestHandler(this.token, this.role);

  factory AuthenticatedRequestHandler.fromJson(Map<String, dynamic> json) =>
      _$AuthenticatedRequestHandlerFromJson(json);

  Map<String, dynamic> toJson() => _$AuthenticatedRequestHandlerToJson(this);

  Map<String, String> get _headers {
    if (token == null) throw MissingTokenException();
    return <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${token.value}'
    };
  }
}

@JsonSerializable()
class AuthToken {
  String value;

  AuthToken(this.value);

  factory AuthToken.fromJson(Map<String, dynamic> json) =>
      _$AuthTokenFromJson(json);
}

class MissingTokenException implements Exception {}

Future<RegisteredUser> register(
    String email, String password, String name) async {
  // send request
  final http.Response res = await http.post(AUTH_URL + "/register",
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
  final http.Response res = await http.post(AUTH_URL + "/login",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'email': email, 'password': password}));

  if (res.statusCode == 200) {
    AuthToken token = AuthToken.fromJson(json.decode(res.body));
    AuthenticatedRequestHandler reqHandler =
        await AuthenticatedRequestHandler.getInstance();
    reqHandler.token = token;
    reqHandler.serialise();
    return true;
  }
  return false;
}

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

const AUTH_URL = 'https://fuzzybroccoli.com/auth';

/// Singleton class for making requests requiring authorisation
class AuthenticatedRequestHandler {
  static final AuthenticatedRequestHandler _instance =
      AuthenticatedRequestHandler._internal();

  AuthToken _token;
  User _user;

  Map<String, String> _headers = <String, String>{
    'Content-Type': 'application/json; charset=UTF-8'
  };

  factory AuthenticatedRequestHandler() {
    // todo: deserialisation
    return _instance;
  }

  Future<bool> sessionIsValid() async {
    final http.Response res =
        await http.post(AUTH_URL + "/session", headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });
    if (res.statusCode == 200) return true;
    return false;
  }

  Future<bool> logout() async {
    final http.Response res =
        await http.post(AUTH_URL + "/logout", headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });
    if (res.statusCode == 200) return true;
    return false;
  }

  AuthenticatedRequestHandler._internal();

  set token(AuthToken token) {
    this._token = token;
    // todo: headers
    // todo: serialisation
  }

  set user(User user) {
    this._user = user;
    // todo: serialisation
  }
}

class AuthToken {
  String value;

  AuthToken({this.value});

  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(value: json['token']);
  }
}

class AuthException implements Exception {}

Future<RegisteredUser> register(
    String email, String password, String name, String username) async {
  // construct request body based on whether a username is supplied
  String body;
  if (username == null) {
    body = jsonEncode(<String, String>{
      'email': email,
      'password': password,
      'name': name,
    });
  } else {
    body = jsonEncode(<String, String>{
      'username': username,
      'email': email,
      'password': password,
      'name': name,
    });
  }

  // send request
  final http.Response res = await http.post(AUTH_URL + "/register",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body);

  // inspect response and return RegisteredUser
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
  final http.Response res = await http.post(AUTH_URL + "/register",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'email': email, 'password': password}));

  if (res.statusCode == 200) {
    AuthToken token = AuthToken.fromJson(json.decode(res.body));
    AuthenticatedRequestHandler().token = token;
    return true;
  }
  return false;
}

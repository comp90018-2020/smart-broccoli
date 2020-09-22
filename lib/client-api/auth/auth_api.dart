import 'package:injectable/injectable.dart';

import '../../models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_base.dart';

@singleton
class AuthApi {
  static const AUTH_URL = ApiBase.BASE_URL + '/auth';

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

  Future<String> login(String email, String password) async {
    final http.Response res = await http.post("$AUTH_URL/login",
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body:
            jsonEncode(<String, String>{'email': email, 'password': password}));

    if (res.statusCode == 200) {
      return json.decode(res.body)['token'];
    } else {
      // todo
      return null;
    }
  }

  // Future<bool> sessionIsValid() async {
  //   final http.Response res =
  //       await http.post(AUTH_URL + "/session", headers: _headers);
  //   if (res.statusCode == 200) return true;
  //   return false;
  // }

  // Future<bool> logout() async {
  //   final http.Response res =
  //       await http.post(AUTH_URL + "/logout", headers: _headers);
  //   if (res.statusCode == 200) {
  //     token = null;
  //     role = null;
  //     return true;
  //   }
  //   return false;
  // }
}

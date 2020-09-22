import 'package:fuzzy_broccoli/client-api/api_base.dart';
import 'package:fuzzy_broccoli/client-api/auth.dart';
import '../models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserModel {
  AuthModel _authService;

  UserModel(this._authService);

  Future<RegisteredUser> getUser() async {
    http.Response response =
        await ApiBase.get('/user/profile', authToken: _authService.token);
    return RegisteredUser.fromJson(jsonDecode(response.body));
  }
}

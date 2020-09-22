import 'package:injectable/injectable.dart';
import '../../models/user.dart';
import '../api_base.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

@singleton
class UserApi {
  ApiBase _apiBase;

  UserApi(this._apiBase);

  Future<RegisteredUser> getUser() async {
    http.Response response = await _apiBase.get('/user/profile');
    return RegisteredUser.fromJson(jsonDecode(response.body));
  }
}

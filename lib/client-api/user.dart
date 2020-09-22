import 'package:fuzzy_broccoli/client-api/api_base.dart';
import 'package:fuzzy_broccoli/client-api/auth.dart';
import '../models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserModel {
  AuthModel _authService;
  static const USER_URL = ApiBase.BASE_URL + '/user';

  UserModel(this._authService);

  Future<RegisteredUser> getUser() async {
    http.Response response = await http.get('$USER_URL/profile',
        headers: ApiBase.headers(authToken: _authService.token));
    print(response.body);
    return RegisteredUser.fromJson(jsonDecode(response.body));
  }

  Future<int> getUserId() async {
    RegisteredUser user = await getUser();
    print(user);
    print(user.id);
    return user.id;
  }
}

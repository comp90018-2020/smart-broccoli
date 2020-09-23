import 'package:fuzzy_broccoli/client-api/api_base.dart';
import 'package:fuzzy_broccoli/client-api/auth.dart';
import '../models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserModel {
  AuthModel _authModel;
  static const USER_URL = ApiBase.BASE_URL + '/user';

  UserModel(this._authModel);

  Future<RegisteredUser> getUser() async {
    http.Response response = await http.get('$USER_URL/profile',
        headers: ApiBase.headers(authToken: _authModel.token));
    print(response.body);
    return RegisteredUser.fromJson(jsonDecode(response.body));
  }

  Future<RegisteredUser> updateUser({email, password, name}) async {
    Map<String, String> body = {};
    if (email != null) body['email'] = email;
    if (password != null) body['password'] = password;
    if (name != null) body['name'] = name;
    final http.Response response = await http.patch('$USER_URL/profile',
        headers: ApiBase.headers(authToken: _authModel.token),
        body: jsonEncode(body));
    return RegisteredUser.fromJson(jsonDecode(response.body));
  }

  Future<int> getUserId() async {
    RegisteredUser user = await getUser();
    print(user);
    print(user.id);
    return user.id;
  }
}

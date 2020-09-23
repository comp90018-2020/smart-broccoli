import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/user.dart';
import 'api_base.dart';
import 'auth.dart';

class UserModel {
  AuthModel _authModel;
  static const USER_URL = ApiBase.BASE_URL + '/user';

  UserModel(this._authModel);

  Future<RegisteredUser> getUser() async {
    http.Response response = await http.get('$USER_URL/profile',
        headers: ApiBase.headers(authToken: _authModel.token));

    if (response.statusCode == 200)
      return RegisteredUser.fromJson(jsonDecode(response.body));
    else if (response.statusCode == 401)
      throw UnauthorisedRequestException();
    else if (response.statusCode == 403)
      throw ForbiddenRequestException();
    throw Exception('Unable to get user: unknown error occurred');
  }

  Future<RegisteredUser> updateUser({email, password, name}) async {
    Map<String, String> body = {};
    if (email != null) body['email'] = email;
    if (password != null) body['password'] = password;
    if (name != null) body['name'] = name;

    final http.Response response = await http.patch('$USER_URL/profile',
        headers: ApiBase.headers(authToken: _authModel.token),
        body: jsonEncode(body));

    if (response.statusCode == 200)
      return RegisteredUser.fromJson(jsonDecode(response.body));
    else if (response.statusCode == 401)
      throw UnauthorisedRequestException();
    else if (response.statusCode == 403)
      throw ForbiddenRequestException();
    throw Exception('Unable to update user: unknown error occurred');
  }

  Future<int> getUserId() async {
    RegisteredUser user = await getUser();
    print(user);
    print(user.id);
    return user.id;
  }
}

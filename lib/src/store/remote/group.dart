import 'dart:convert';

import 'package:fuzzy_broccoli/models.dart';
import 'package:http/http.dart' as http;

import 'api_base.dart';
import 'auth.dart';

/// Class for making group management requests
class GroupModel {
  static const GROUP_URL = ApiBase.BASE_URL + '/group';

  /// AuthModel object used to obtain token for requests
  AuthModel _authModel;

  /// Constructor for external use
  GroupModel(this._authModel);

  /// Return a list of all groups to which the authenticated user belongs
  /// (i.e. owns or has joined).
  Future<List<Group>> getGroups() async {
    http.Response response = await http.get(GROUP_URL,
        headers: ApiBase.headers(authToken: _authModel.token));

    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((repr) => Group.fromJson(repr))
          .toList();
    }

    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    throw Exception('Unable to get groups: unknown error occurred');
  }

  /// Get a group by specified [id].
  Future<Group> getGroup(int id) async {
    http.Response response = await http.get('$GROUP_URL/$id',
        headers: ApiBase.headers(authToken: _authModel.token));

    if (response.statusCode == 200)
      return Group.fromJson(json.decode(response.body));

    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    throw Exception('Unable to get specified group: unknown error occurred');
  }

  /// Create a new group with a specified [name].
  Future<Group> createGroup(String name) async {
    http.Response response = await http.post(GROUP_URL,
        headers: ApiBase.headers(authToken: _authModel.token),
        body: jsonEncode(<String, String>{'name': name}));

    if (response.statusCode == 201)
      return Group.fromJson(json.decode(response.body));

    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    if (response.statusCode == 409) throw GroupCreateException();
    throw Exception('Unable to create group: unknown error occurred');
  }
}

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:smart_broccoli/models.dart';
import 'package:tuple/tuple.dart';

import '../../data/group.dart';
import 'api_base.dart';

class GroupApi {
  static const GROUP_URL = ApiBase.BASE_URL + '/group';

  /// HTTP client (mock client can be specified for testing)
  http.Client _http;

  GroupApi({http.Client mocker}) {
    _http = mocker ?? IOClient();
  }

  /// Return a list of all groups to which a user belongs (owns or has joined).
  ///
  /// Caveat: The `members` field of each will be null. Use `getMembers` to retrieve
  /// this list.
  Future<List<Group>> getGroups(String token) async {
    http.Response response =
        await _http.get(GROUP_URL, headers: ApiBase.headers(authToken: token));

    if (response.statusCode == 200)
      return (json.decode(response.body) as List)
          .map((repr) => Group.fromJson(repr))
          .toList();

    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    throw Exception('Unable to get groups: unknown error occurred');
  }

  /// Get a group by specified [id].
  ///
  /// Caveat: The `members` field of each group will be null. Use `getMembers`
  /// to retrieve the list of members.
  Future<Group> getGroup(String token, int id) async {
    http.Response response = await _http.get('$GROUP_URL/$id',
        headers: ApiBase.headers(authToken: token));

    if (response.statusCode == 200)
      return Group.fromJson(json.decode(response.body));

    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    if (response.statusCode == 404) throw GroupNotFoundException();
    throw Exception('Unable to get specified group: unknown error occurred');
  }

  /// Return a list of members as (User, GroupRole) tuples for a group with
  /// specified [id].
  Future<List<Tuple2<User, GroupRole>>> getMembers(String token, int id) async {
    http.Response response = await _http.get('$GROUP_URL/$id/member',
        headers: ApiBase.headers(authToken: token));

    if (response.statusCode == 200)
      return (json.decode(response.body) as List)
          .map((repr) => Tuple2(User.fromJson(repr),
              repr['role'] == 'owner' ? GroupRole.OWNER : GroupRole.MEMBER))
          .toList();

    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    throw Exception(
        'Unable to get members of specified group: unknown error occurred');
  }

  /// Create a new group with a specified [name].
  Future<Group> createGroup(String token, String name) async {
    http.Response response = await _http.post(GROUP_URL,
        headers: ApiBase.headers(authToken: token),
        body: jsonEncode(<String, String>{'name': name}));

    if (response.statusCode == 201)
      return Group.fromJson(json.decode(response.body));

    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    if (response.statusCode == 409) throw GroupCreateException();
    throw Exception('Unable to create group: unknown error occurred');
  }

  /// Update the name of a group with specified [id].
  ///
  /// Return a `Group` object constructed from the server's response.
  ///
  /// Caveat: The `members` field of the returned object will be null. Use
  /// `getMembers` to retrieve the list of members.
  Future<Group> updateGroup(String token, int id, String name) async {
    http.Response response = await _http.patch('$GROUP_URL/$id',
        headers: ApiBase.headers(authToken: token),
        body: jsonEncode(<String, String>{'name': name}));

    if (response.statusCode == 200)
      return Group.fromJson(json.decode(response.body));

    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    if (response.statusCode == 409) throw GroupCreateException();
    throw Exception('Unable to update group: unknown error occurred');
  }

  /// Delete a group with specified [id].
  Future<void> deleteGroup(String token, int id) async {
    http.Response response = await _http.delete('$GROUP_URL/$id',
        headers: ApiBase.headers(authToken: token));

    if (response.statusCode == 204) return;
    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    throw Exception('Unable to delete group: unknown error occurred');
  }

  /// Refresh the unique code for a group with specified [id].
  ///
  /// Return a new `Group` object with an updated `code` field.
  /// The existing code will be discarded and users will no longer be able to
  /// join with it.
  ///
  /// Caveat: The `members` field of the returned object will be null. Use
  /// `getMembers` to retrieve this list.
  Future<Group> refreshCode(String token, int id) async {
    http.Response response = await _http.post('$GROUP_URL/$id/code',
        headers: ApiBase.headers(authToken: token));

    if (response.statusCode == 200)
      return Group.fromJson(json.decode(response.body));

    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    throw Exception('Unable to refresh group token: unknown error occurred');
  }

  /// Join a group, either by specified [name] or [code].
  /// Return a `Group` object corresponding to the group joined.
  Future<Group> joinGroup(String token, {String name, String code}) async {
    if (name == null && code == null)
      throw ArgumentError('`name` or `code` parameter must be specified');

    Map<String, String> body = name != null ? {'name': name} : {'code': code};

    http.Response response = await _http.post('$GROUP_URL/join',
        headers: ApiBase.headers(authToken: token), body: jsonEncode(body));

    if (response.statusCode == 200)
      return Group.fromJson(json.decode(response.body));

    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    if (response.statusCode == 404) throw GroupNotFoundException();
    if (response.statusCode == 422) throw AlreadyInGroupException();
    throw Exception('Unable to join group: unknown error occurred');
  }

  /// Leave a group with specified [id].
  Future<void> leaveGroup(String token, int id) async {
    http.Response response = await _http.post('$GROUP_URL/$id/leave',
        headers: ApiBase.headers(authToken: token));

    if (response.statusCode == 204) return;
    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    throw Exception('Unable to leave group: unknown error occurred');
  }

  /// Remove a member from a group.
  Future<void> kickMember(String token, int groupId, int memberId) async {
    http.Response response = await _http.post('$GROUP_URL/$groupId/member/kick',
        headers: ApiBase.headers(authToken: token),
        body: jsonEncode(<String, int>{'memberId': memberId}));

    if (response.statusCode == 204) return;
    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    throw Exception('Unable to kick member: unknown error occurred');
  }
}

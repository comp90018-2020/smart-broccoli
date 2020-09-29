import 'dart:convert';

import 'package:fuzzy_broccoli/models.dart';
import 'package:http/http.dart' as http;
import 'package:tuple/tuple.dart';

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
  /// If the optional parameter [fetchMembers] is `true`, each `Group` object
  /// in the list will contain a non-null `members` field (a list of the same
  /// format returned by `getMembers`). Otherwise, the `members` field of each
  /// group will be `null`.
  Future<List<Group>> getGroups({bool fetchMembers = false}) async {
    http.Response response = await http.get(GROUP_URL,
        headers: ApiBase.headers(authToken: _authModel.token));

    if (response.statusCode == 200) {
      List groups = (json.decode(response.body) as List)
          .map((repr) => Group.fromJson(repr))
          .toList();
      if (fetchMembers)
        for (final Group group in groups)
          try {
            group.members = await getMembers(group.id);
          } catch (err) {
            continue;
          }
      return groups;
    }

    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    throw Exception('Unable to get groups: unknown error occurred');
  }

  /// Get a group by specified [id].
  /// If the optional parameter [fetchMembers] is `true`, each `Group` object
  /// in the list will contain a non-null `members` field (a list of the same
  /// format returned by `getMembers`). Otherwise, the `members` field of each
  /// group will be `null`.
  Future<Group> getGroup(int id, {bool fetchMembers = false}) async {
    http.Response response = await http.get('$GROUP_URL/$id',
        headers: ApiBase.headers(authToken: _authModel.token));

    if (response.statusCode == 200) {
      Group group = Group.fromJson(json.decode(response.body));
      if (fetchMembers) group.members = await getMembers(group.id);
      return group;
    }

    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    throw Exception('Unable to get specified group: unknown error occurred');
  }

  /// Return a list of (user, role) tuples, each corresponding to a member in
  /// the group with specified [id].
  Future<List<Tuple2<User, GroupRole>>> getMembers(int id) async {
    http.Response response = await http.get('$GROUP_URL/$id/member',
        headers: ApiBase.headers(authToken: _authModel.token));

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

  /// Synchronise an updated [group] with the server.
  /// Return a `Quiz` object constructed from the server's response. All fields
  /// should be equal in content.
  ///
  /// Usage:
  /// [group] should be a `Group` object obtained by `getGroup`, `getGroups`
  /// or `createGroup`. Mutate the `name` field then invoke this method.
  Future<Group> updateGroup(Group group) async {
    http.Response response = await http.patch('$GROUP_URL/${group.id}',
        headers: ApiBase.headers(authToken: _authModel.token),
        body: jsonEncode(<String, String>{'name': group.name}));

    if (response.statusCode == 200)
      return Group.fromJson(json.decode(response.body));

    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    if (response.statusCode == 409) throw GroupCreateException();
    throw Exception('Unable to update group: unknown error occurred');
  }

  /// Delete a [group].
  ///
  /// Usage:
  /// [group] should be a `Group` object obtained by `getGroup`, `getGroups`
  /// or `createGroup`.
  Future<void> deleteGroup(Group group) async {
    http.Response response = await http.delete('$GROUP_URL/${group.id}',
        headers: ApiBase.headers(authToken: _authModel.token));

    if (response.statusCode == 204) return;
    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    throw Exception('Unable to delete group: unknown error occurred');
  }

  /// Refresh the unique token for the group with specified [id].
  /// The existing token will be discarded and users will no longer be able to
  /// join with it.
  Future<Group> refreshToken(int id) async {
    http.Response response = await http.post('$GROUP_URL/$id/code',
        headers: ApiBase.headers(authToken: _authModel.token));

    if (response.statusCode == 200)
      return Group.fromJson(json.decode(response.body));

    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    throw Exception('Unable to refresh group token: unknown error occurred');
  }

  /// Join a group, either by specified [name] or [code].
  Future<Group> joinGroup({String name, String code}) async {
    if (name == null && code == null)
      throw ArgumentError('`name` or `code` parameter must be specified');

    Map<String, String> body = name != null ? {'name': name} : {'code': code};

    http.Response response = await http.post('$GROUP_URL/join',
        headers: ApiBase.headers(authToken: _authModel.token),
        body: jsonEncode(body));

    if (response.statusCode == 200)
      return Group.fromJson(json.decode(response.body));

    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    if (response.statusCode == 404) throw GroupNotFoundException();
    if (response.statusCode == 422) throw AlreadyInGroupException();
    throw Exception('Unable to join group: unknown error occurred');
  }

  /// Leave a [group].
  ///
  /// Usage:
  /// [group] should be a `Group` object obtained by `getGroup`, `getGroups`
  /// or `createGroup`.
  Future<void> leaveGroup(Group group) async {
    http.Response response = await http.post('$GROUP_URL/${group.id}/leave',
        headers: ApiBase.headers(authToken: _authModel.token));

    if (response.statusCode == 204) return;
    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    throw Exception('Unable to leave group: unknown error occurred');
  }

  /// Remove the member with [memberId] from the group with [groupId].
  Future<void> kickMember(int groupId, int memberId) async {
    http.Response response = await http.post('$GROUP_URL/$groupId/member/kick',
        headers: ApiBase.headers(authToken: _authModel.token),
        body: jsonEncode(<String, int>{'memberId': memberId}));

    if (response.statusCode == 204) return;
    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    throw Exception('Unable to kick member: unknown error occurred');
  }
}

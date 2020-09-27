import 'package:tuple/tuple.dart';

import 'user.dart';

enum GroupRole { OWNER, MEMBER }

class Group {
  int id;
  String name;
  bool defaultGroup;
  String code;

  List<Tuple2<User, GroupRole>> members;

  Group(this.id, this.name,
      {this.defaultGroup: false, this.code, this.members});

  factory Group.fromJson(Map<String, dynamic> json,
          {List<Tuple2<User, GroupRole>> members}) =>
      Group(json['id'], json['name'],
          defaultGroup: json['defaultGroup'],
          code: json['code'],
          members: members);
}

/// Exception thrown when the server is unable to create a group due to the
/// name already being in use.
class GroupCreateException implements Exception {}

/// Exception thrown when the server is unable to change a group name due to
/// the new name already being in use.
class GroupRenameException implements Exception {}

/// Exception thrown when attempting to join a group of which the user is
/// already a member.
class AlreadyInGroupException implements Exception {}

/// Exception thrown when attempting an operation on a group which could not
/// be found.
class GroupNotFoundException implements Exception {}

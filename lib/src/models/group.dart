import 'package:tuple/tuple.dart';

import 'user.dart';

enum GroupRole { OWNER, MEMBER }

/// Class representing a study group/class
/// Do not instantiate this class; it will be created for you and returned
/// by methods in `GroupModel`.
class Group {
  int _id;
  int get id => _id;
  bool _defaultGroup;
  bool get defaultGroup => _defaultGroup;
  String _code;
  String get code => _code;

  String name;

  /// Read-only list of members (with roles); mutating this list will have
  /// no effect on the server
  List<Tuple2<User, GroupRole>> members;

  /// Constructor for internal use only
  Group._internal(
      this._id, this.name, this._defaultGroup, this._code, this.members);

  factory Group.fromJson(Map<String, dynamic> json,
          {List<Tuple2<User, GroupRole>> members}) =>
      Group._internal(json['id'], json['name'], json['defaultGroup'],
          json['code'], members);
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

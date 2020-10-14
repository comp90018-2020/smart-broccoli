import 'package:smart_broccoli/models.dart';

import 'user.dart';

enum GroupRole { OWNER, MEMBER }

/// Class representing a study group/class
/// Do not instantiate this class; it will be created for you and returned
/// by methods in `GroupModel`.
/// The `name` field may be changed to update the group name. If doing so,
/// pass the `Group` object to `GroupModel.updateGroup` to synchronise the
/// change with the server. Do not change other fields.
class Group {
  final int id;
  final String name;
  final bool defaultGroup;
  final String code;
  final GroupRole role;

  /// List of members; mutating this list will have no effect on the server
  List<User> members;

  /// Constructor for internal use only
  Group._internal(this.id, this.name, this.defaultGroup, this.code, this.role,
      this.members);

  factory Group.fromJson(Map<String, dynamic> json) => Group._internal(
        json['id'],
        json['name'],
        json['defaultGroup'],
        json['code'],
        json['role'] == 'member' ? GroupRole.MEMBER : GroupRole.OWNER,
        (json['members'] as List)?.map((repr) => User.fromJson(repr))?.toList(),
      );

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'defaultGroup': defaultGroup,
      'code': code,
      'role': role == GroupRole.MEMBER ? 'member' : 'owner',
      'members': members?.map((member) => member.toJson())?.toList(),
    };
  }
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

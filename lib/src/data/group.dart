import 'package:smart_broccoli/src/store/remote/api_base.dart';

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
  // List<User> members;

  /// Constructor for internal use only
  Group._internal(this.id, this.name, this.defaultGroup, this.code, this.role);

  /// Name with default group annotation
  String get nameWithDefaultGroup =>
      defaultGroup ? "$name (Default group)" : name;

  factory Group.fromJson(Map<String, dynamic> json) => Group._internal(
        json['id'],
        json['name'],
        json['defaultGroup'],
        json['code'],
        json['role'] == 'member' ? GroupRole.MEMBER : GroupRole.OWNER,
      );

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'defaultGroup': defaultGroup,
      'code': code,
      'role': role == GroupRole.MEMBER ? 'member' : 'owner',
    };
  }
}

/// Exception thrown when the server is unable to create a group due to the
/// name already being in use.
class GroupCreateException extends ApiException {
  GroupCreateException()
      : super("Cannot create group, group name already exists");
}

/// Exception thrown when the server is unable to change a group name due to
/// the new name already being in use.
class GroupRenameException extends ApiException {
  GroupRenameException() : super("Cannot rename group, name is already in use");
}

/// Exception thrown when attempting to join a group of which the user is
/// already a member.
class AlreadyInGroupException extends ApiException {
  AlreadyInGroupException() : super("Already in group");
}

/// Exception thrown when attempting an operation on a group which could not
/// be found.
class GroupNotFoundException extends ApiException {
  GroupNotFoundException() : super("Group not found");
}

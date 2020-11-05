import 'package:smart_broccoli/src/store/remote/api_base.dart';

import 'group.dart';

enum UserType { REGISTERED, UNREGISTERED }

class User {
  final UserType type;
  final int id;
  final int pictureId;
  final String email;
  final String _name;
  String get name => _name != null ? _name : "(anonymous member)";
  bool get isAnonymous => _name == null;

  final GroupRole groupRole;

  User._internal(this.type, this.id, this.pictureId, this.email, this._name,
      this.groupRole);

  factory User.fromJson(Map<String, dynamic> json) => User._internal(
        json['role'] == 'user'
            ? UserType.REGISTERED
            : json['role'] == 'participant'
                ? UserType.UNREGISTERED
                : null,
        json['id'],
        json['pictureId'],
        json['email'],
        json['name'],
        json['role'] == 'owner'
            ? GroupRole.OWNER
            : json['role'] == 'member'
                ? GroupRole.MEMBER
                : null,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'pictureId': pictureId,
        'email': email,
        'name': name,
        'role': type == UserType.REGISTERED
            ? 'user'
            : type == UserType.UNREGISTERED
                ? 'participant'
                : groupRole == GroupRole.OWNER
                    ? 'owner'
                    : groupRole == GroupRole.MEMBER
                        ? 'member'
                        : null,
      };
}

class RegistrationException extends ApiException {
  RegistrationException() : super("Failed to register");
}

/// Exception thrown when attempting to register (or update the profile of a
/// user) with an already registered email
class RegistrationConflictException extends RegistrationException {
  @override
  String toString() => 'Another account with the same email already exists';
}

/// Exception thrown when login is unsuccessful
class LoginFailedException extends ApiException {
  LoginFailedException() : super("Incorrect username or password");
}

/// Exception thrown when a participant user fails to register with the server
class ParticipantJoinException extends RegistrationException {
  @override
  String toString() => 'Cannot join';
}

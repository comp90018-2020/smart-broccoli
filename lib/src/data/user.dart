enum UserType { REGISTERED, UNREGISTERED }

class User {
  final UserType type;
  final int id;
  final int pictureId;
  final String email;
  final String name;

  User._internal(this.type, this.id, this.pictureId, this.email, this.name);

  factory User.fromJson(Map<String, dynamic> json) => User._internal(
      json['role'] == 'user' ? UserType.REGISTERED : UserType.UNREGISTERED,
      json['id'],
      json['pictureId'],
      json['email'],
      json['name']);

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'id': id, 'email': email, 'name': name};
}

class RegistrationException implements Exception {}

/// Exception thrown when attempting to register (or update the profile of a
/// user) with an already registered email
class RegistrationConflictException extends RegistrationException {}

/// Exception thrown when login is unsuccessful
class LoginFailedException implements Exception {}

/// Exception thrown when a participant user fails to register with the server
class ParticipantJoinException extends RegistrationException {}

/// Exception thrown when a user cannot be promoted to a registered user
/// (e.g. the user is already registered)
class ParticipantPromotionException extends RegistrationException {}

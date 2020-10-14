enum UserType { REGISTERED, UNREGISTERED }

class User {
  final UserType type;
  final int id;
  final String email;
  final String name;

  User(this.type, this.id, this.email, this.name);

  factory User.fromJson(Map<String, dynamic> json) => User(
      json['role'] == 'user' ? UserType.REGISTERED : UserType.UNREGISTERED,
      json['id'],
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

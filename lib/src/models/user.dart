/// Class representing a user
/// Abstract class; not for instantiation.
abstract class User {
  int _id;
  int get id => _id;
  String email;
  String name;

  User(this._id, this.email, this.name);

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'id': id, 'email': email, 'name': name};
}

/// User with login credientials (lecturer, coordinator)
class RegisteredUser extends User {
  RegisteredUser(int id, String email, String name) : super(id, email, name);

  factory RegisteredUser.fromJson(Map<String, dynamic> json) =>
      RegisteredUser(json['id'], json['email'], json['name']);
}

/// User without login credentials (student)
class ParticipantUser extends User {
  ParticipantUser(int id, {String email, String name}) : super(id, email, name);

  factory ParticipantUser.fromJson(Map<String, dynamic> json) =>
      ParticipantUser(json['id'], email: json['email'], name: json['name']);
}

class RegistrationException implements Exception {}

/// Exception thrown when attempting to register with an already registered email
class RegistrationConflictException extends RegistrationException {}

/// Exception thrown when login is unsuccessful
class LoginFailedException implements Exception {}

/// Exception thrown when a participant user fails to register with the server
class ParticipantJoinException extends RegistrationException {}

/// Exception thrown when a user cannot be promoted to a registered user
/// (e.g. the user is already registered)
class ParticipantPromotionException extends RegistrationException {}

enum Role { CREATOR, USER }

/// User with login credientials (lecturer, coordinator)
class RegisteredUser {
  int id;
  String email;
  String name;

  RegisteredUser({this.id, this.email, this.name});

  factory RegisteredUser.fromJson(Map<String, dynamic> json) {
    return RegisteredUser(
        id: json['id'], email: json['email'], name: json['name']);
  }
}

class RegistrationException implements Exception {}

/// Exception thrown when attempting to register with an already registered email
class RegistrationConflictException extends RegistrationException {}

/// Exception thrown when login is unsuccessful
class LoginFailedException implements Exception {}

/// User without login credentials (student)
class ParticipantUser {}

/// Exception thrown when a participant user failed to register with the server
class ParticipantJoinException extends RegistrationException {}

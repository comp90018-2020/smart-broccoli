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
class RegistrationConflictException implements RegistrationException {}

/// User without login credentials (student)
class ParticipantUser {}

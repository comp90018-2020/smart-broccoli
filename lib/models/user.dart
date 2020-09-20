abstract class User {}

/// User with login credientials (lecturer, coordinator)
class RegisteredUser extends User {
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

/// Exception thrown when a user cannot be registered due to conflict(s)
class RegistrationConflictException implements RegistrationException {
  List<String> conflicts;
  RegistrationConflictException(this.conflicts);
}

/// User without login credentials (student)
class ParticipantUser extends User {}

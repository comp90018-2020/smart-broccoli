/// User with login credientials (lecturer, coordinator)
class RegisteredUser {
  int id;
  String email;
  String name;
  String username;

  RegisteredUser({this.id, this.email, this.name, this.username});

  factory RegisteredUser.fromJson(Map<String, dynamic> json) {
    return RegisteredUser(
        id: json['id'],
        email: json['email'],
        name: json['name'],
        username: json.containsKey('username') ? json['username'] : null);
  }
}

class RegistrationException implements Exception {}

/// Exception thrown when a user cannot be registered due to conflict(s)
class RegistrationConflictException implements RegistrationException {
  List<String> conflicts;
  RegistrationConflictException(this.conflicts);
}

/// User without login credentials (student)
class ParticipantUser {}

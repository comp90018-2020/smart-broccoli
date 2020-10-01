class User {
  int _id;
  int get id => _id;
  String email;
  String name;

  User(this._id, this.email, this.name);

  factory User.fromJson(Map<String, dynamic> json) =>
      User(json['id'], json['email'], json['name']);

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'id': id, 'email': email, 'name': name};
}

/// User with login credientials (lecturer, coordinator)
class RegisteredUser extends User {
  /// To update the user's password, set this field then pass this object to
  /// `UserModel.updateUser` to synchronise with server. This field is `null`.
  String password;

  RegisteredUser(int id, String email, String name) : super(id, email, name);

  factory RegisteredUser.fromJson(Map<String, dynamic> json) =>
      RegisteredUser(json['id'], json['email'], json['name']);

  Map<String, dynamic> toJson() {
    Map map = super.toJson();
    if (password != null) map['password'] = password;
    return map;
  }
}

/// User without login credentials (student)
class ParticipantUser extends User {
  ParticipantUser(int id, {String email, String name}) : super(id, email, name);

  factory ParticipantUser.fromJson(Map<String, dynamic> json) =>
      ParticipantUser(json['id'], email: json['email'], name: json['name']);
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

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/socket_data/state.dart';

class Welcome {
  final List<User> players;
  final GroupRole role;
  final SessionState state;

  Welcome._internal(this.players, this.role, this.state);
  factory Welcome.fromJson(Map<String, dynamic> json) => Welcome._internal(
    (json['players'] as List).map((e) => User.fromJson(e)).toList(),
    json['role'],
    json['state'],
  );
}

class User {
  final int id;
  final String name;
  final int pictureId;

  User._internal(this.id, this.name, this.pictureId);

  factory User.fromJson(Map<String, dynamic> json) => User._internal(
        json['id'],
        json['name'],
        json['pictureId'],
      );
}

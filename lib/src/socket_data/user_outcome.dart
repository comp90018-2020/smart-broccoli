import 'user.dart';
import 'record.dart';

class UserOutcome {
  final User player;
  final Record record;

  UserOutcome._internal(this.player, this.record);

  factory UserOutcome.fromJson(Map<String, dynamic> json) =>
      UserOutcome._internal(
        User.fromJson(json['player']),
        Record.fromJson(json['record']),
      );
}

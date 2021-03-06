import 'user.dart';
import 'record.dart';

class UserRank {
  final SocketUser player;
  final Record record;

  UserRank._internal(this.player, this.record);

  factory UserRank.fromJson(Map<String, dynamic> json) => UserRank._internal(
        SocketUser.fromJson(json['player']),
        Record.fromJson(json['record']),
      );
}

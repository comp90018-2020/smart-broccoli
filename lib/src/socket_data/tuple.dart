import 'user.dart';
import 'record.dart';

class Tuple {
  final User player;
  final Record record;

  Tuple._internal(this.player, this.record);

  factory Tuple.fromJson(Map<String, dynamic> json) =>
      Tuple._internal(
        User.fromJson(json['player']),
        Record.fromJson(json['record']),
      );
}


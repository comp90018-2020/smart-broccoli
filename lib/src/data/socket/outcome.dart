import 'user_rank.dart';
import 'record.dart';

class Outcome {
  final int question;
  final List<UserRank> leaderboard;
  Outcome._internal(this.question, this.leaderboard);
  factory Outcome.fromJson(Map<String, dynamic> json) => Outcome._internal(
        json['question'],
        (json['leaderboard'] as List).map((e) => UserRank.fromJson(e)).toList(),
      );
}

class OutcomeUser extends Outcome {
  final Record record;
  final UserRank playerAhead;
  OutcomeUser._internal(
      int question, List<UserRank> leaderboard, this.record, this.playerAhead)
      : super._internal(question, leaderboard);
  factory OutcomeUser.fromJson(Map<String, dynamic> json) =>
      OutcomeUser._internal(
          json['question'],
          (json['leaderboard'] as List)
              .map((e) => UserRank.fromJson(e))
              .toList(),
          Record.fromJson(json['record']),
          json['playerAhead'] == null
              ? null
              : UserRank.fromJson(json['playerAhead']));
}

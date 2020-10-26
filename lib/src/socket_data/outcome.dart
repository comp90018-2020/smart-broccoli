import 'user_outcome.dart';
import 'record.dart';

class Outcome {
  final int question;
  final List<UserRank> leaderboard;
  Outcome._internal(this.question, this.leaderboard);
  factory Outcome.fromJson(Map<String, dynamic> json) => Outcome._internal(
        json['question'],
        json['leaderboard'].map((e) => UserRank.fromJson(e)),
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
          json['leaderboard'].map((e) => UserRank.fromJson(e)),
          Record.fromJson(json['record']),
          json['playerAhead'] ?? UserRank.fromJson(json['playerAhead']));
}

import 'user_outcome.dart';
import 'record.dart';

class Outcome {
  final int question;
  final List<UserRank> leaderboard;

  Outcome(this.question, List leaderboard)
      : leaderboard = leaderboard.map((e) => UserRank.fromJson(e));

  factory Outcome.fromJson(Map<String, dynamic> json) =>
      Outcome(json['question'], json['leaderboard']);
}

class OutcomeUser extends Outcome {
  final Record record;
  final UserRank playerAhead;

  OutcomeUser._internal(
      int question, List<UserRank> leaderboard, this.record, this.playerAhead)
      : super(question, leaderboard);

  factory OutcomeUser.fromJson(Map<String, dynamic> json) =>
      OutcomeUser._internal(
          json['question'],
          json['leaderboard'],
          Record.fromJson(json['record']),
          (json['playerAhead'] == null)
              ? null
              : UserRank.fromJson(json['playerAhead']));
}

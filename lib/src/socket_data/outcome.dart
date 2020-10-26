import 'user_outcome.dart';
import 'record.dart';

class Outcome {
  int question;
  List<UserRank> leaderBoard;

  Outcome._internal(
      this.question, this.leaderBoard);

  factory Outcome.fromJson(Map<String, dynamic> json) => Outcome._internal(
    json['question'],
    (json['leaderboard'] as List).map((e) => UserRank.fromJson(e)),
  );

}

class OutcomeUser extends Outcome {
  Record record;
  UserRank playerAhead;

  Outcome._internal(this.question, this.leaderBoard);

  OutcomeUser(Map<String, dynamic> json) : super(question, leaderBoard) {

    this.record = Record.fromJson(json['record']);
    this.playerAhead = (json['playerAhead'] == null)
        ? null
        : UserRank.fromJson(json['playerAhead']);
  }
}



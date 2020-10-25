import 'user_outcome.dart';
import 'record.dart';

class OutcomeHost {
  int question;
  List<UserOutcome> leaderBoard;

  OutcomeHost(Map<String, dynamic> json) {
    this.question = json['question'];
    this.leaderBoard = parse(json);
  }

  List<UserOutcome> parse(Map<String, dynamic> json) {
    List<UserOutcome> userOutcomes = [];
    List leaderBoard = (json['leaderboard'] as List);
    for (var value in leaderBoard) {
      UserOutcome outcome = UserOutcome.fromJson(value);
      userOutcomes.add(outcome);
    }

    return userOutcomes;
  }
}

class OutcomeUser extends OutcomeHost {
  Record record;
  UserOutcome playerAhead;

  OutcomeUser(Map<String, dynamic> json) : super(json) {
    if (json['record'] == null) {
      this.record = null;
    } else {
      this.record = Record.fromJson(json['record']);
    }

    if (json['playerAhead'] == null) {
      this.playerAhead = null;
    } else {
      this.playerAhead = UserOutcome.fromJson(json['playerAhead']);
    }
  }
}

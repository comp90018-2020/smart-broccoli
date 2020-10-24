import 'tuple.dart';
import 'record.dart';

class OutcomeUser {
  int question;
  List<Tuple> leaderBoard;
  Record record;
  Tuple playerAhead;

  OutcomeUser(Map<String, dynamic> json) {
    this.question = json['question'];
    this.leaderBoard = outcomeUserMod(json);

    if(json['record'] == null) {this.record = null;}
    else {this.record = Record.fromJson(json['record']);}

    if(json['playerAhead'] == null) {this.playerAhead = null;}
    else {this.playerAhead = Tuple.fromJson(json['playerAhead']);}
  }

  List<Tuple> outcomeUserMod(Map<String, dynamic> json)
  {
    List<Tuple> tuples = [];
    List tempTuple = (json['leaderboard'] as List);
    for(var values in tempTuple)
    {
      Tuple temp = Tuple.fromJson(values);
      tuples.add(temp);
    }

    this.record = Record.fromJson(json['record']);
    this.playerAhead = Tuple.fromJson(json['playerAhead']);

    return tuples;
  }
}

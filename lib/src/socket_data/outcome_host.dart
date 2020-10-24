import 'tuple.dart';

class OutcomeHost {
  int question;
  List<Tuple> leaderBoard;

  OutcomeHost(Map<String, dynamic> json) {
    this.question = json['question'];
    this.leaderBoard = outcomeHostMod(json);
  }

  List<Tuple> outcomeHostMod(Map<String, dynamic> json) {
    List<Tuple> tuples = [];
    List tempTuple = (json['leaderboard'] as List);
    for (var values in tempTuple) {
      Tuple temp = Tuple.fromJson(values);
      tuples.add(temp);
    }

    return tuples;
  }
}

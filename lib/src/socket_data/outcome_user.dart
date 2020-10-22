import 'tuple.dart';
import 'record.dart';

class OutcomeUser {
  int question;
  List<Tuple> leaderBoard;
  Record record;
  Tuple playerAhead;


  OutcomeUser(Map<String, dynamic> json){
    this.question = json['question'];
    this.leaderBoard = OutcomeUser_Mod(json);
    this.record = Record.fromJson(json['record']);
    this.playerAhead = Tuple.fromJson(json['playerAhead']);

  }

  List<Tuple> OutcomeUser_Mod(Map<String, dynamic> json)
  {
    List<Tuple> tuples = [];
    List temp_tuple = (json['leaderboard'] as List);
    for(var values in temp_tuple)
    {
      Tuple temp = Tuple.fromJson(values);
      tuples.add(temp);
    };
    return tuples;
  }

}
import 'tuple.dart';

class OutcomeHost {
  int question;
  List<Tuple> leaderBoard;

  OutcomeHost(Map<String, dynamic> json){
    this.question = json['question'];
    this.leaderBoard = OutcomeHost_Mod(json);
  }

  List<Tuple> OutcomeHost_Mod(Map<String, dynamic> json)
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
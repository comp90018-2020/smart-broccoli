class Question {
  int no;
  String text;
  int pictureId;
  List<Option> options; // json
  bool tf;
  int time;

  Question(Map<String, dynamic> json){
    this.no = json['no'];
    this.text = json['text'];
    this.pictureId = json['pictureId'];
    this.options = Question_Mod(json);
    this.tf = json['tf'];
    this.time = json['time'];
  }

  List<Option> Question_Mod(Map<String, dynamic> json)
  {
    List<Option> options = [];
    List temp_opt = (json['options'] as List);
    for(var values in temp_opt)
    {
      //Option temp = new Option.fromJson(values);
      Option temp = Option.fromJson(values);
      //temp.fromJson(values);
      options.add(temp);
    };
    return options;
  }

}

class Option {
  final String text;

  Option._internal(this.text);

  factory Option.fromJson(Map<String, dynamic> json) =>
      Option._internal(
        json['text'],
      );
}


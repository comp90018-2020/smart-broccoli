class Question {
  int no;
  String text;
  int pictureId;
  List<Option> options; // json
  bool tf;
  int time;

  Question(Map<String, dynamic> json) {
    this.no = json['no'];
    this.text = json['text'];
    this.pictureId = json['pictureId'];
    if (json['options'] == null) {
      this.options = null;
    } else {
      this.options = questionMod(json);
    }

    this.tf = json['tf'];
    this.time = json['time'];
  }

  List<Option> questionMod(Map<String, dynamic> json) {
    List<Option> options = [];
    List tempOpt = (json['options'] as List);
    for (var values in tempOpt) {
      //Option temp = new Option.fromJson(values);
      Option temp = Option.fromJson(values);
      //temp.fromJson(values);
      options.add(temp);
    }
    return options;
  }
}

class Option {
  final String text;

  Option._internal(this.text);

  factory Option.fromJson(Map<String, dynamic> json) => Option._internal(
        json['text'],
      );
}

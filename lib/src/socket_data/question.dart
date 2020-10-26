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
      this.options = parse(json);
    }

    this.tf = json['tf'];
    this.time = json['time'];
  }

  List<Option> parse(Map<String, dynamic> json) {
    List<Option> options = [];
    List opts = (json['options'] as List);
    for (var values in opts) {
      Option opt = Option.fromJson(values);
      options.add(opt);
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

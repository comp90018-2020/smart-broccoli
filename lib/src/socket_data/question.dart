import 'package:smart_broccoli/src/data.dart';

class NextQuestion {
  final Question question;
  final int time;
  final int totalQuestions;

  NextQuestion._internal(this.question, this.time, this.totalQuestions);
  factory NextQuestion.fromJson(Map<String, dynamic> json) =>
      NextQuestion._internal(
        json['question']['type'] == 'truefalse'
            ? TFQuestion.fromJson(json['question'])
            : MCQuestion.fromJson(json['question']),
        json['time'],
        json['totalQuestions'],
      );
}
//
// class Question {
//   int no;
//   String text;
//   int pictureId;
//   List<Option> options; // json
//   bool tf;
//   int numCorrect;
//
//   Question(Map<String, dynamic> json) {
//     this.no = json['no'];
//     this.text = json['text'];
//     this.pictureId = json['pictureId'];
//
//     if (json['options'] == null) {
//       this.options = null;
//     } else {
//       this.options = parse(json);
//     }
//
//     this.tf = json['tf'];
//     this.numCorrect = json['numCorrect'];
//   }
//
//   List<Option> parse(Map<String, dynamic> json) {
//     List<Option> options = [];
//     List opts = (json['options'] as List);
//     for (var values in opts) {
//       Option opt = Option.fromJson(values);
//       options.add(opt);
//     }
//
//     return options;
//   }
// }
//
// class Option {
//   final String text;
//
//   Option._internal(this.text);
//
//   factory Option.fromJson(Map<String, dynamic> json) => Option._internal(
//         json['text'],
//       );
// }

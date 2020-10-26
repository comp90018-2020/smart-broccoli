import 'package:smart_broccoli/src/socket_data/record.dart';

class CorrectAnswer {
  final Answer answer;
  final Record record;

  CorrectAnswer._internal(this.answer, this.record);

  factory CorrectAnswer.fromJson(Map<String, dynamic> json) =>
      CorrectAnswer._internal(
        Answer.fromJson(json['answer']),
        Record.fromJson(json['record']),
      );
}

class Answer {
  int question;
  List<int> mcSelection;
  bool tfSelection;

  Answer._internal(this.question, this.mcSelection, this.tfSelection);

  factory Answer.fromJson(Map<String, dynamic> json) => Answer._internal(
        json['question'],
        json['MCSelection'],
        json['TFSelection'],
      );

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'question': question,
      'MCSelection': mcSelection,
      'TFSelection': tfSelection,
    };
  }
}

import 'record.dart';

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
  final List<dynamic> mcSelection;
  bool tfSelection;

  Answer(this.question, {List<dynamic> mcSelection, this.tfSelection})
      : this.mcSelection = mcSelection ?? [];

  factory Answer.fromJson(Map<String, dynamic> json) => Answer(
        json['question'],
        mcSelection: json['MCSelection'],
        tfSelection: json['TFSelection'],
      );

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'question': question,
      'MCSelection': mcSelection,
      'TFSelection': tfSelection,
    };
  }
}

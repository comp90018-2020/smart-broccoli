import 'package:fuzzy_broccoli/models.dart';

enum QuizType { LIVE, SELF_PACED }

class Quiz {
  int id;
  String title;
  String description;

  int groupId;
  QuizType type;
  bool isActive;

  int timeLimit;
  List<Question> questions;

  Quiz(this.id, this.title, this.groupId, this.type,
      {this.description, this.isActive, this.timeLimit, this.questions});

  factory Quiz.fromJson(Map<String, dynamic> json) => Quiz(
      json['id'],
      json['title'],
      json['groupId'],
      json['type'] == 'live' ? QuizType.LIVE : QuizType.SELF_PACED,
      description: json['description'],
      isActive: json['isActive'],
      timeLimit: json['timeLimit']);
}

abstract class Question {
  int id;
  String text;
  int imgId;

  Question(this.id, this.text, this.imgId);
}

// True/false question
class TFQuestion extends Question {
  bool answer;

  TFQuestion(int id, String text, int imgId, this.answer)
      : super(id, text, imgId);

  factory TFQuestion.fromJson(Map<String, dynamic> json) =>
      TFQuestion(json['id'], json['text'], json['imgid'], json['tf']);
}

// Multiple choice question
class MCQuestion extends Question {
  List<QuestionOption> options;

  MCQuestion(int id, String text, int imgId, {this.options})
      : super(id, text, imgId);

  factory MCQuestion.fromJson(Map<String, dynamic> json) =>
      MCQuestion(json['id'], json['text'], json['imgid']);
}

// Option for multiple choice question
class QuestionOption {
  String text;
  bool correct;

  QuestionOption(this.text, this.correct);

  factory QuestionOption.fromJson(Map<String, dynamic> json) =>
      QuestionOption(json['text'], json['correct']);
}

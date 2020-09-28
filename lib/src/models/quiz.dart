enum QuizType { LIVE, SELF_PACED }

class Quiz {
  int id;
  String title;
  String description;

  int groupId;
  QuizType type;
  bool isActive;

  int timeLimit;
  List<Question> questions = [];

  Quiz(this.id, this.title, this.groupId, this.type,
      {this.description, this.isActive, this.timeLimit, this.questions});

  factory Quiz.fromJson(Map<String, dynamic> json) => Quiz(
      json['id'],
      json['title'],
      json['groupId'],
      json['type'] == 'live' ? QuizType.LIVE : QuizType.SELF_PACED,
      description: json['description'],
      isActive: json['isActive'],
      timeLimit: json['timeLimit'],
      questions: (json['questions'] as List)?.map((question) =>
          question['type'] == 'truefalse'
              ? TFQuestion.fromJson(question)
              : MCQuestion.fromJson(question))?.toList());

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'groupId': groupId,
      'type': type == QuizType.LIVE ? 'live' : 'self paced',
      'description': description,
      'isActive': isActive,
      'timeLimit': timeLimit,
      'questions': questions.map((question) => question.toJson())
    };
  }
}

abstract class Question {
  int id;
  String text;
  int imgId;

  Question(this.id, this.text, this.imgId);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'id': id, 'text': text, 'imgId': imgId};
  }
}

// True/false question
class TFQuestion extends Question {
  bool answer;

  TFQuestion(int id, String text, int imgId, this.answer)
      : super(id, text, imgId);

  factory TFQuestion.fromJson(Map<String, dynamic> json) =>
      TFQuestion(json['id'], json['text'], json['imgid'], json['tf']);

  Map<String, dynamic> toJson() {
    Map map = super.toJson();
    map['type'] = 'truefalse';
    map['tf'] = answer;
    return map;
  }
}

// Multiple choice question
class MCQuestion extends Question {
  List<QuestionOption> options = [];

  MCQuestion(int id, String text, int imgId, {this.options})
      : super(id, text, imgId);

  factory MCQuestion.fromJson(Map<String, dynamic> json) =>
      MCQuestion(json['id'], json['text'], json['imgid'],
          options: (json['options'] as List)
              .map((option) => QuestionOption.fromJson(option))
              .toList());

  Map<String, dynamic> toJson() {
    Map map = super.toJson();
    map['type'] = 'choice';
    map['options'] = options.map((option) => option.toJson());
    return map;
  }
}

// Option for multiple choice question
class QuestionOption {
  String text;
  bool correct;

  QuestionOption(this.text, this.correct);

  factory QuestionOption.fromJson(Map<String, dynamic> json) =>
      QuestionOption(json['text'], json['correct']);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'text': text, 'correct': correct};
  }
}

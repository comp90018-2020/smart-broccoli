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
}

abstract class Question {
  int id;
  String text;
  int imgId;
}

// True/false question
class TFQuestion {
  bool answer;
}

// Multiple choice question
class MCQuestion {
  List<QuestionOption> options;
}

// Option for multiple choice question
class QuestionOption {
  String text;
  bool correct;
}

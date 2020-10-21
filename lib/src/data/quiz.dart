import 'game.dart';
import 'group.dart';

enum QuizType { LIVE, SELF_PACED }

/// Object representing a quiz
/// Instances of this class are returned when fetching quizzes from the server.
/// Additional instances of this class (i.e. not fetched from the server) are
/// to be constructed when the user creates a new quiz. A new quiz can be
/// synchronised with the server by passing it to `QuizModel.createQuiz`.
class Quiz {
  /// ID of the quiz (for quizzes fetched from server only)
  final int id;

  /// User's role. This field is non-null for quizzes in the list returned by
  /// `getQuizzes`; however, it will be null for a quiz returned by `getQuiz`
  final GroupRole role;

  String title;
  String description;

  int groupId;
  QuizType type;
  bool isActive;
  final List<GameSession> sessions;

  int timeLimit;
  List<Question> questions;

  /// Construtor for use when user creates a new quiz
  factory Quiz(String title, int groupId, QuizType type,
          {String description,
          bool isActive,
          int timeLimit,
          List<Question> questions}) =>
      Quiz._internal(null, GroupRole.OWNER, title, groupId, type, description,
          isActive, timeLimit, questions, null);

  /// Constructor for internal use only
  Quiz._internal(
      this.id,
      this.role,
      this.title,
      this.groupId,
      this.type,
      this.description,
      this.isActive,
      this.timeLimit,
      this.questions,
      this.sessions);

  factory Quiz.fromJson(Map<String, dynamic> json) {
    final Iterable sessions = (json['Sessions'] as List)?.map((session) {
      session['quizId'] = json['id'];
      session['groupId'] = json['groupId'];
      return GameSession.fromJson(session);
    });
    Quiz quiz = Quiz._internal(
        json['id'],
        json['role'] == 'owner' ? GroupRole.OWNER : GroupRole.MEMBER,
        json['title'],
        json['groupId'],
        json['type'] == 'live' ? QuizType.LIVE : QuizType.SELF_PACED,
        json['description'],
        json['active'],
        json['timeLimit'],
        null,
        sessions != null ? List.unmodifiable(sessions) : null);
    quiz.questions = (json['questions'] as List)
        ?.map((question) => question['type'] == 'truefalse'
            ? TFQuestion.fromJson(quiz, question)
            : MCQuestion.fromJson(quiz, question))
        ?.toList();
    return quiz;
  }

  // note: sessions not serialised
  Map<String, dynamic> toJson() {
    Map json = <String, dynamic>{
      'id': id,
      'title': title,
      'groupId': groupId,
      'type': type == QuizType.LIVE ? 'live' : 'self paced',
      'description': description,
      'active': isActive,
      'timeLimit': timeLimit,
    };
    if (questions != null)
      json['questions'] =
          questions.map((question) => question.toJson()).toList();
    return json;
  }
}

/// Object representing a question in a quiz
/// `Quiz` instances hold a list of this class.
/// Abstract class; not for instantiation.
abstract class Question {
  Quiz _quiz;

  Quiz get quiz => _quiz;

  int _id;

  int get id => _id;
  String text;
  int imgId;

  Question(this._quiz, this._id, this.text, this.imgId);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'quizId': quiz.id,
      'text': text,
      'imgId': imgId
    };
  }
}

/// Object representing a true/false question
/// Instances of this class should be constructed when the user creates new
/// true/false questions. To modify an existing true/false question, mutate
/// the fields directly. The `Quiz` object holding the question must be
/// synchronised with the server to finalise any changes.
class TFQuestion extends Question {
  bool answer;

  /// Constructor for use when user creates a new true/false question
  TFQuestion(Quiz quiz, String text, this.answer, {int imgId})
      : super(quiz, null, text, imgId);

  /// Constructor for internal use only
  TFQuestion._internal(Quiz quiz, int id, String text, int imgId, this.answer)
      : super(quiz, id, text, imgId);

  factory TFQuestion.fromJson(Quiz quiz, Map<String, dynamic> json) =>
      TFQuestion._internal(
          quiz, json['id'], json['text'], json['imgid'], json['tf']);

  Map<String, dynamic> toJson() {
    Map map = super.toJson();
    map['type'] = 'truefalse';
    map['tf'] = answer;
    return map;
  }
}

/// Object representing a multiple choice question
/// Instances of this class should be constructed when the user creates new
/// multiple choice questions. To modify an existing multiple choice question,
/// mutate the fields directly. The `Quiz` object holding the question must be
/// synchronised with the server to finalise any changes.
class MCQuestion extends Question {
  List<QuestionOption> options;

  /// Constructor for use when user creates a new multiple choice question
  MCQuestion(Quiz quiz, String text, this.options, {int imgId})
      : super(quiz, null, text, imgId);

  /// Constructor for internal use only
  MCQuestion._internal(Quiz quiz, int id, String text, int imgId,
      {this.options})
      : super(quiz, id, text, imgId);

  factory MCQuestion.fromJson(Quiz quiz, Map<String, dynamic> json) =>
      MCQuestion._internal(quiz, json['id'], json['text'], json['imgid'],
          options: (json['options'] as List)
              .map((option) => QuestionOption.fromJson(option))
              .toList());

  Map<String, dynamic> toJson() {
    Map map = super.toJson();
    map['type'] = 'choice';
    map['options'] = options.map((option) => option.toJson()).toList();
    return map;
  }
}

/// Object representing an option of a multiple choice question
/// Instances of this class should be constructed when the user creates new
/// multiple choice options. To modify an existing multiple choice option,
/// mutate the fields directly. The `Quiz` object holding the multiple choice
/// question must be synchronised with the server to finalise any changes.
class QuestionOption {
  String text;
  bool correct;

  /// Constructor for use when user creates a new multiple choice option
  QuestionOption(this.text, this.correct);

  factory QuestionOption.fromJson(Map<String, dynamic> json) =>
      QuestionOption(json['text'], json['correct']);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'text': text, 'correct': correct};
  }
}

/// Exception thrown when a quiz cannot be found by the server
class QuizNotFoundException implements Exception {}

/// Exception thrown when a question cannot be found by the server
/// (thrown when setting a question picture)
class QuestionNotFoundException implements Exception {}

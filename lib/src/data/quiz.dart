import 'game.dart';
import 'group.dart';

enum QuizType { SMART_LIVE, LIVE, SELF_PACED }

/// Object representing a quiz
/// Instances of this class are returned when fetching quizzes from the server.
/// Additional instances of this class (i.e. not fetched from the server) are
/// to be constructed when the user creates a new quiz. A new quiz can be
/// synchronised with the server by passing it to `QuizModel.createQuiz`.
class Quiz implements Comparable<Quiz> {
  /// ID of the quiz (for quizzes fetched from server only)
  final int id;
  final DateTime updatedTimestamp;

  final int pictureId;

  /// User's role. This field is non-null for quizzes in the list returned by
  /// `getQuizzes`; however, it will be null for a quiz returned by `getQuiz`
  final GroupRole role;

  String title;
  String description;

  int groupId;
  QuizType _type;
  bool isActive;
  final List<GameSession> sessions;

  int timeLimit;
  List<Question> questions;

  final bool complete;

  /// Construtor for use when user creates a new quiz
  factory Quiz(String title, int groupId, QuizType type,
          {String description,
          bool isActive,
          int timeLimit,
          List<Question> questions}) =>
      Quiz._internal(null, null, null, GroupRole.OWNER, title, groupId, type,
          description, isActive, timeLimit, questions, null, false);

  /// Constructor for internal use only
  Quiz._internal(
    this.id,
    this.updatedTimestamp,
    this.pictureId,
    this.role,
    this.title,
    this.groupId,
    this._type,
    this.description,
    this.isActive,
    this.timeLimit,
    this.questions,
    this.sessions,
    this.complete,
  );

  factory Quiz.fromJson(Map<String, dynamic> json) {
    final Iterable sessions = (json['Sessions'] as List)?.map((session) {
      session['quizId'] = json['id'];
      session['groupId'] = json['groupId'];
      return GameSession.fromJson(session);
    });
    Quiz quiz = Quiz._internal(
        json['id'],
        DateTime.parse(json['updatedAt'] ?? '2020-01-01 00:00:00.000'),
        json['pictureId'],
        json['role'] == 'owner' ? GroupRole.OWNER : GroupRole.MEMBER,
        json['title'],
        json['groupId'],
        json['type'] == 'live' ? QuizType.LIVE : QuizType.SELF_PACED,
        json['description'],
        json['active'],
        json['timeLimit'],
        null,
        sessions != null ? List.unmodifiable(sessions) : null,
        json['complete']);
    quiz.questions = (json['questions'] as List)
        ?.map((question) => question['type'] == 'truefalse'
            ? TFQuestion.fromJson(question)
            : MCQuestion.fromJson(question))
        ?.toList();
    return quiz;
  }

  // note: sessions not serialised
  Map<String, dynamic> toJson() {
    Map json = <String, dynamic>{
      'id': id,
      'title': title,
      'groupId': groupId,
      'type': _type == QuizType.LIVE ? 'live' : 'self paced',
      'description': description,
      'active': isActive,
      'timeLimit': timeLimit,
      'complete': complete
    };
    if (questions != null)
      json['questions'] =
          questions.map((question) => question.toJson()).toList();
    return json;
  }

  @override
  int compareTo(Quiz other) {
    int thisType = this.type.index;
    int otherType = other.type.index;

    if (thisType == otherType)
      return other.updatedTimestamp.compareTo(this.updatedTimestamp);
    else
      return otherType - thisType;
  }

  /// Type of quiz
  QuizType get type {
    // Live quiz
    if (this._type == QuizType.LIVE) return QuizType.LIVE;
    // Determine if smart session exists (a self-paced quiz with session)
    var smartSession = this.sessions?.firstWhere(
        (session) =>
            session.quizType == QuizType.SELF_PACED &&
            session.state != GameSessionState.ENDED, orElse: () {
      return null;
    });
    return smartSession == null ? QuizType.SELF_PACED : QuizType.SMART_LIVE;
  }

  /// Set type
  set type(QuizType type) => this._type = type;
}

/// Object representing a question in a quiz
/// `Quiz` instances hold a list of this class.
/// Abstract class; not for instantiation.
abstract class Question {
  /// Unique question id for questions from API only
  final int id;

  /// Question number for questions from gameplay server only
  final int no;

  String text;
  int pictureId;

  Question({this.id, this.no, this.text, this.pictureId});

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'no': no,
      'text': text,
      'pictureId': pictureId
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
  TFQuestion(String text, this.answer, {int pictureId})
      : super(text: text, pictureId: pictureId);

  /// Constructor for internal use only
  TFQuestion._internal(int id, int no, String text, int pictureId, this.answer)
      : super(id: id, no: no, text: text, pictureId: pictureId);

  factory TFQuestion.fromJson(Map<String, dynamic> json) =>
      TFQuestion._internal(
          json['id'], json['no'], json['text'], json['pictureId'], json['tf']);

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
  int numCorrect;

  /// Constructor for use when user creates a new multiple choice question
  MCQuestion(String text, this.options, {int pictureId, this.numCorrect})
      : super(text: text, pictureId: pictureId);

  /// Constructor for internal use only
  MCQuestion._internal(int id, int no, String text, int pictureId,
      {this.options, this.numCorrect})
      : super(id: id, no: no, text: text, pictureId: pictureId);

  factory MCQuestion.fromJson(Map<String, dynamic> json) =>
      MCQuestion._internal(
          json['id'], json['no'], json['text'], json['pictureId'],
          numCorrect: json['numCorrect'],
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

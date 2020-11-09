/// Update payload from Firebase
class GroupUpdatePayload {
  final int groupId;

  GroupUpdatePayload._internal(this.groupId);
  factory GroupUpdatePayload.fromJson(Map<String, dynamic> json) =>
      GroupUpdatePayload._internal(json['groupId']);
}

/// Update payload from Firebase
class QuizUpdatePayload {
  final int groupId;
  final int quizId;

  QuizUpdatePayload._internal(this.groupId, this.quizId);
  factory QuizUpdatePayload.fromJson(Map<String, dynamic> json) =>
      QuizUpdatePayload._internal(json['groupId'], json['quizId']);
}

/// Update payload from Firebase
class SessionActivatePayload {
  final int groupId;
  final int quizId;
  final int sessionId;

  SessionActivatePayload._internal(this.sessionId, this.groupId, this.quizId);
  factory SessionActivatePayload.fromJson(Map<String, dynamic> json) =>
      SessionActivatePayload._internal(
          json['sessionId'], json['groupId'], json['quizId']);
}

class SessionStart {
  final int quizId;
  final int sessionId;

  SessionStart._internal(this.sessionId, this.quizId);
  factory SessionStart.fromJson(Map<String, dynamic> json) =>
      SessionStart._internal(json['sessionId'], json['quizId']);
}

class QuestionAnswered {
  final int question;
  final int count;
  final int total;

  QuestionAnswered._internal(this.question, this.count, this.total);

  factory QuestionAnswered.fromJson(Map<String, dynamic> json) =>
      QuestionAnswered._internal(
        json['question'],
        json['count'],
        json['total'],
      );
}

class Record {
  final int oldPos;
  final int newPos;
  final int bonusPoints;
  final int points;
  final int streak;

  Record._internal(
      this.oldPos, this.newPos, this.bonusPoints, this.points, this.streak);

  factory Record.fromJson(Map<String, dynamic> json) => Record._internal(
        json['oldPos'],
        json['newPos'],
        json['bonusPoints'],
        json['points'],
        json['streak'],
      );
}

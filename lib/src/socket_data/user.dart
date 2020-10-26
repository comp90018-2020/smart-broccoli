class User {
  final int id;
  final String name;
  final int pictureId;

  User._internal(this.id, this.name, this.pictureId);

  factory User.fromJson(Map<String, dynamic> json) => User._internal(
        json['id'],
        json['name'],
        json['pictureId'],
      );
}

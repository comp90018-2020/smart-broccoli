class SocketUser {
  final int id;
  final String name;
  final int pictureId;

  SocketUser._internal(this.id, this.name, this.pictureId);

  factory SocketUser.fromJson(Map<String, dynamic> json) =>
      SocketUser._internal(
        json['id'],
        json['name'],
        json['pictureId'],
      );
}

class SocketUser {
  final int id;
  final String _name;
  final int pictureId;

  String get name => _name != null ? _name : "(anonymous member)";

  SocketUser._internal(this.id, this._name, this.pictureId);

  factory SocketUser.fromJson(Map<String, dynamic> json) =>
      SocketUser._internal(
        json['id'],
        json['name'],
        json['pictureId'],
      );
}

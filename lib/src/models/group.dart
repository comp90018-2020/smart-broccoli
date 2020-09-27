import 'package:tuple/tuple.dart';

import 'user.dart';

enum GroupRole { OWNER, MEMBER }

class Group {
  int id;
  String name;
  bool defaultGroup;
  String code;

  List<Tuple2<User, GroupRole>> members;

  Group(this.id, this.name,
      {this.defaultGroup: false, this.code, this.members});

  factory Group.fromJson(Map<String, dynamic> json,
          {List<Tuple2<User, GroupRole>> members}) =>
      Group(json['id'], json['name'],
          defaultGroup: json['defaultGroup'],
          code: json['code'],
          members: members);
}

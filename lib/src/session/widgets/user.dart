import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:smart_broccoli/theme.dart';

/// Represents a user in a list
class UserItem extends StatelessWidget {
  final String name;

  UserItem(this.name);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      // Profile image
      Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
              color: Colors.green, borderRadius: BorderRadius.circular(100))),
      // Name
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Text(name, style: SmartBroccoliTheme.listItemTextStyle),
      )
    ]);
  }
}

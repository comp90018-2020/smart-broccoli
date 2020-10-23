import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'profile_picture.dart';
import 'profile_promoting.dart';
import 'table_items.dart';

class ProfileJoined extends StatefulWidget {
  /// Whether fields are in edit mode
  final bool _isEdit;

  ProfileJoined(this._isEdit);

  @override
  State<StatefulWidget> createState() => new _ProfileJoinedState();
}

class _ProfileJoinedState extends State<ProfileJoined> {
  final TextEditingController _nameController = new TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Profile picture
        ProfilePicture(widget._isEdit),
        // Table
        Container(
          padding: const EdgeInsets.all(24),
          child: TableCard(
            [
              NameTableRow(widget._isEdit, _nameController),
            ],
          ),
        ),
        // Promote user
        AnimatedSwitcher(
          duration: Duration(milliseconds: 100),
          child: widget._isEdit
              ? Container()
              : Column(
                  children: [
                    const Padding(
                      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                      child: const Text(
                        "Registering lets you login from another device and create groups and quizzes",
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // The button
                    SizedBox(
                      width: 150,
                      child: RaisedButton(
                          onPressed: () => initRegister(),
                          child: const Text("Register")),
                    ),
                  ],
                ),
        )
      ],
    );
  }

  // Code to promote a joined user to a registered user
  void initRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ProfilePromoting()),
    );
  }
}

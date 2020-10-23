import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'profile_picture.dart';
import 'promoting_profile.dart';
import 'util_table.dart';

class JoinedProfile extends StatefulWidget {
  /// Whether fields are in edit mode
  final bool _isEdit;

  JoinedProfile(this._isEdit);

  @override
  State<StatefulWidget> createState() => new _JoinedProfileState();
}

class _JoinedProfileState extends State<JoinedProfile> {
  final TextEditingController _nameController = new TextEditingController();
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  final TextEditingController _confirmPasswordController =
      new TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
          child: Material(
            type: MaterialType.card,
            elevation: 3,
            child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: const {
                0: FlexColumnWidth(0.3),
                1: FlexColumnWidth(0.7)
              },
              border: TableBorder.all(width: 0.8, color: Colors.black12),
              children: [
                NameTableRow(widget._isEdit, _nameController),
              ],
            ),
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
                          child: Text("Register")),
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
      MaterialPageRoute(builder: (context) => PromotingProfile()),
    );
  }
}

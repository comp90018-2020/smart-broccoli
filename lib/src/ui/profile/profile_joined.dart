import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models/user_profile.dart';
import 'package:smart_broccoli/src/ui/profile/profile_editor.dart';
import 'package:smart_broccoli/src/ui/shared/dialog.dart';

import 'profile_picture.dart';
import 'profile_promoting.dart';
import 'table_items.dart';

class ProfileJoined extends ProfileEditor {
  ProfileJoined(bool isEdit, {Key key}) : super(isEdit, key: key);

  @override
  State<StatefulWidget> createState() => new _ProfileJoinedState();
}

class _ProfileJoinedState extends ProfileEditorState {
  final _nameController = TextEditingController();

  @override
  void initState() {
    final User user =
        Provider.of<UserProfileModel>(context, listen: false).user;
    _nameController.text = user == null || user.isAnonymous ? "" : user.name;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Profile picture
        ProfilePicture(widget.isEdit),
        // Table
        Container(
          padding: const EdgeInsets.all(24),
          child: TableCard(
            [
              NameTableRow(widget.isEdit, _nameController),
            ],
          ),
        ),
        // Promote user
        AnimatedSwitcher(
          duration: Duration(milliseconds: 100),
          child: widget.isEdit
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

  @override
  Future<bool> commitChanges() async {
    try {
      await Provider.of<UserProfileModel>(context, listen: false).updateUser(
          name: _nameController.text.isEmpty ? null : _nameController.text);
      return true;
    } catch (_) {
      showErrorDialog(context, "Cannot update profile");
      return false;
    }
  }

  // Code to promote a joined user to a registered user
  void initRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ProfilePromoting()),
    );
  }
}

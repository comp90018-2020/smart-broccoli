import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui/shared/dialog.dart';

import 'profile_picture.dart';
import 'profile_promoting.dart';
import 'table_items.dart';
import 'profile_editor.dart';

class ProfileJoined extends ProfileEditor {
  ProfileJoined(User user, bool isEdit, {Key key})
      : super(user, isEdit, key: key);

  @override
  State<StatefulWidget> createState() => new _ProfileJoinedState();
}

class _ProfileJoinedState extends ProfileEditorState {
  final _nameController = TextEditingController();

  @override
  void initState() {
    discardChanges();
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
              NameTableRow(
                widget.isEdit,
                _nameController,
                hintText: widget.user.isAnonymous ? "(anonymous)" : null,
              ),
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
    if (_nameController.text.isEmpty) {
      showErrorDialog(context, "Name field is required");
      return false;
    }
    try {
      await Provider.of<UserProfileModel>(context, listen: false)
          .updateUser(name: _nameController.text);
      return true;
    } catch (_) {
      showErrorDialog(context, "Cannot update profile");
      return false;
    }
  }

  @override
  Future<void> discardChanges() async {
    _nameController.text = widget.user.isAnonymous ? "" : widget.user.name;
  }

  // Code to promote a joined user to a registered user
  void initRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ProfilePromoting()),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui/shared/indicators.dart';

import 'profile_picture.dart';
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

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    discardChanges();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Profile picture
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: ProfilePicture(widget.isEdit),
          ),
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
      ),
    );
  }

  @override
  Future<bool> commitChanges() async {
    if (!_formKey.currentState.validate()) {
      return false;
    }
    return Provider.of<UserProfileModel>(context, listen: false)
        .updateUser(name: _nameController.text)
        .then((_) => true);
  }

  @override
  Future<void> discardChanges() async {
    _nameController.text = widget.user.isAnonymous ? "" : widget.user.name;
  }

  // Code to promote a joined user to a registered user
  void initRegister() {
    Navigator.of(context).pushNamed("/profile/promoting");
  }
}

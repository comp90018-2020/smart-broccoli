import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models.dart';

import 'profile_picture.dart';
import 'profile_fields.dart';
import 'profile_editor.dart';

class ProfileJoined extends ProfileEditor {
  ProfileJoined(User user, bool isEdit, {Key key})
      : super(user, isEdit, key: key);

  @override
  State<StatefulWidget> createState() => new _ProfileJoinedState();
}

class _ProfileJoinedState extends ProfileEditorState {
  // Name controller
  final _nameController = TextEditingController();

  // Form
  final _formKey = GlobalKey<FormState>();
  // Used to determine Autovalidatemode
  bool _formSubmitted = false;

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
        Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: ProfilePicture(widget.isEdit),
        ),

        // Name field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          child: Form(
            key: _formKey,
            child: NameField(
              widget.isEdit,
              _nameController,
              _formSubmitted,
              hintText: widget.user.isAnonymous ? "(anonymous)" : null,
            ),
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
                      padding: const EdgeInsets.fromLTRB(24, 38, 24, 20),
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
    setState(() => _formSubmitted = true);
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

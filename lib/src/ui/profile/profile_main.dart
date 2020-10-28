import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui/shared/page.dart';

import 'profile_editor.dart';
import 'profile_registered.dart';
import 'profile_joined.dart';
import 'profile_picture.dart';

/// Container for profile page elements
class ProfileMain extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _ProfileMainState();
}

class _ProfileMainState extends State<ProfileMain> {
  /// Global key corresponding to the child page
  final GlobalKey<ProfileEditorState> key = GlobalKey();

  /// Whether edit mode is activated
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    Provider.of<UserProfileModel>(context, listen: false)
        .getUser(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPage(
      title: "Profile",
      hasDrawer: !_isEdit,

      // discard changes
      appbarLeading: _isEdit
          ? IconButton(
              icon: Icon(Icons.close),
              enableFeedback: false,
              splashRadius: 20,
              onPressed: () async {
                if (!await _confirmDiscardDialogue()) return;
                setState(() {
                  _isEdit = false;
                });
                key.currentState.discardChanges();
              },
            )
          : null,

      // Save/edit
      appbarActions: [
        CupertinoButton(
          child: Text(_isEdit ? "Save" : "Edit",
              style: const TextStyle(color: Colors.white)),
          onPressed: () async {
            if (_isEdit && await key.currentState.commitChanges()) {
              _showSuccessDialogue();
              setState(() {
                _isEdit = false;
              });
            } else if (!_isEdit) {
              setState(() {
                _isEdit = true;
              });
            }
          },
        )
      ],

      // Render appropriate page
      child: SingleChildScrollView(
        child: Consumer<UserProfileModel>(
          builder: (context, profile, child) {
            if (profile.user == null)
              // Placeholder profile picture
              return Column(children: [
                ProfilePicture(false),
              ]);

            return profile.user.type == UserType.UNREGISTERED
                ? ProfileJoined(profile.user, _isEdit, key: key)
                : ProfileRegistered(profile.user, _isEdit, key: key);
          },
        ),
      ),
    );
  }

  Future<void> _showSuccessDialogue() async => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Success"),
          content: Text("Profile updated"),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: Navigator.of(context).pop,
            ),
          ],
        ),
      );

  Future<bool> _confirmDiscardDialogue() async => showDialog(
      context: context,
      builder: (_) => AlertDialog(
            title: Text("Confirm"),
            content: Text("No changes will be saved"),
            actions: [
              TextButton(
                  child: Text("Cancel"),
                  onPressed: () => Navigator.of(context).pop(false)),
              TextButton(
                child: Text("OK"),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
      barrierDismissible: false);
}

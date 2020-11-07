import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui/shared/dialog.dart';
import 'package:smart_broccoli/src/ui/shared/page.dart';
import 'package:smart_broccoli/src/ui/shared/indicators.dart';

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

  /// Whether the update has been submitted
  bool _committed = false;

  @override
  void initState() {
    super.initState();

    // On login, the user must be loaded
    // So at most, the user should just be slightly out of date
    Provider.of<UserProfileModel>(context, listen: false)
        .getUser(refresh: true)
        .catchError((_) => null);
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
                if (!await showConfirmDialog(
                    context, "No changes will be saved",
                    barrierDismissable: true)) return;
                setState(() => _isEdit = false);
                key.currentState.discardChanges();
              },
            )
          : null,

      // Save/edit
      appbarActions: [
        Builder(
            builder: (context) => IconButton(
                  disabledColor: Color(0x65ffffff),
                  icon: Icon(_isEdit ? Icons.check : Icons.edit),
                  padding: EdgeInsets.zero,
                  splashRadius: 20,
                  onPressed: _committed ? null : () => _edit(context),
                ))
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

  /// Profile edits
  void _edit(BuildContext context) async {
    if (_isEdit) {
      setState(() => _committed = true);

      try {
        if (await key.currentState.commitChanges()) {
          showSnackBar(context, 'Profile updated');
          setState(() => _isEdit = false);
        }
      } catch (err) {
        showErrSnackBar(context, err.toString(), dim: true);
      }

      setState(() => _committed = false);
    } else
      setState(() => _isEdit = true);
  }
}

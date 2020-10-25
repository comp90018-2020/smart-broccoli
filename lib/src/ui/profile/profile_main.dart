import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models.dart';

import 'package:smart_broccoli/src/ui/shared/page.dart';
import 'profile_registered.dart';
import 'profile_joined.dart';

/// Container for profile page elements
class ProfileMain extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _ProfileMainState();
}

class _ProfileMainState extends State<ProfileMain> {
  final bool isRegistered = false;

  /// Whether edit mode is activated
  bool _isEdit = false;

  @override
  Widget build(BuildContext context) {
    return CustomPage(
      title: "Profile",
      hasDrawer: true,

      // Save/edit
      appbarActions: [
        CupertinoButton(
          child: Text(_isEdit ? "Save" : "Edit",
              style: const TextStyle(color: Colors.white)),
          onPressed: () {
            setState(() {
              _isEdit = !_isEdit;
            });
          },
        )
      ],

      // Render appropriate page
      child: Consumer<UserProfileModel>(
        builder: (context, profile, child) => SingleChildScrollView(
          child: profile.user.type == UserType.UNREGISTERED
              ? ProfileJoined(_isEdit)
              : ProfileRegistered(_isEdit),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui/shared/dialog.dart';

import 'package:smart_broccoli/src/ui/shared/page.dart';
import 'profile_registered.dart';
import 'profile_joined.dart';

/// Container for profile page elements
class ProfileMain extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _ProfileMainState();
}

class _ProfileMainState extends State<ProfileMain> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  /// Whether edit mode is activated
  bool _isEdit = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

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
          onPressed: () async {
            if (_isEdit) {
              try {
                // password fields must be empty or match
                if (_passwordController.text != _confirmPasswordController.text)
                  return showErrorDialog(context, "Passwords do not match");
                await Provider.of<UserProfileModel>(context, listen: false)
                    .updateUser(
                  name: _nameController.text.isEmpty
                      ? null
                      : _nameController.text,
                  email: _emailController.text.isEmpty
                      ? null
                      : _emailController.text,
                  password: _passwordController.text.isEmpty
                      ? null
                      : _passwordController.text,
                );
                _showSuccessDialogue();
              } catch (_) {
                showErrorDialog(context, "Cannot update profile");
              }
            }
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
              ? ProfileJoined(_isEdit, _nameController)
              : ProfileRegistered(
                  _isEdit,
                  _nameController,
                  _emailController,
                  _passwordController,
                  _confirmPasswordController,
                ),
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
}

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui/profile/profile_editor.dart';
import 'package:smart_broccoli/src/ui/shared/dialog.dart';

import 'profile_picture.dart';
import 'table_items.dart';

/// Profile page for listed users
class ProfileRegistered extends StatefulWidget implements ProfileEditor {
  ProfileRegistered({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _ProfileRegisteredState();
}

class _ProfileRegisteredState extends ProfileEditorState {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isEdit = false;

  @override
  void initState() {
    _nameController.text =
        Provider.of<UserProfileModel>(context, listen: false).user?.name;
    _emailController.text =
        Provider.of<UserProfileModel>(context, listen: false).user?.email;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfilePicture(_isEdit),

        // Name/email
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: TableCard(
            [
              NameTableRow(
                _isEdit,
                _nameController,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
              ),
              EmailTableRow(
                _isEdit,
                _emailController,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
              ),
            ],
          ),
        ),

        // Password
        if (_isEdit)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 0, bottom: 12),
                  child: Text('Change password',
                      style: Theme.of(context).textTheme.headline6),
                ),
                TableCard(
                  [
                    PasswordTableRow(
                      _isEdit,
                      _passwordController,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).nextFocus(),
                    ),
                    PasswordConfirmTableRow(
                      _isEdit,
                      _confirmPasswordController,
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  void enableEdit() {
    setState(() {
      _isEdit = true;
    });
  }

  @override
  Future<bool> commitChanges() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty) {
      showErrorDialog(context, "Name and email fields are both required");
      return false;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      showErrorDialog(context, "Passwords do not match");
      return false;
    }

    try {
      await Provider.of<UserProfileModel>(context, listen: false).updateUser(
          name: _nameController.text,
          password: _passwordController.text.isEmpty
              ? null
              : _passwordController.text,
          email: _emailController.text);
      _passwordController.clear();
      _confirmPasswordController.clear();
      setState(() {
        _isEdit = false;
      });
      return true;
    } catch (_) {
      showErrorDialog(context, "Cannot update profile");
      return false;
    }
  }
}

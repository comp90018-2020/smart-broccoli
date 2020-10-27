import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui/shared/dialog.dart';
import 'profile_editor.dart';
import 'profile_picture.dart';
import 'table_items.dart';

/// Profile page for listed users
class ProfileRegistered extends ProfileEditor {
  ProfileRegistered(User user, bool isEdit, {Key key})
      : super(user, isEdit, key: key);

  @override
  State<StatefulWidget> createState() => new _ProfileRegisteredState();
}

class _ProfileRegisteredState extends ProfileEditorState {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    discardChanges();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfilePicture(widget.isEdit),

        // Name/email
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: TableCard(
            [
              NameTableRow(
                widget.isEdit,
                _nameController,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
              ),
              EmailTableRow(
                widget.isEdit,
                _emailController,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
              ),
            ],
          ),
        ),

        // Password
        if (widget.isEdit)
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
                      widget.isEdit,
                      _passwordController,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).nextFocus(),
                    ),
                    PasswordConfirmTableRow(
                      widget.isEdit,
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
  Future<bool> commitChanges() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty) {
      showErrorDialog(context, "Name and email fields are both required");
      return false;
    }

    if (!EmailValidator.validate(_emailController.text)) {
      showErrorDialog(context, "Invalid email");
      return false;
    }

    if (_passwordController.text.isNotEmpty &&
        _passwordController.text.length < 8) {
      showErrorDialog(context, "Password must be at least 8 characters");
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
      return true;
    } on RegistrationConflictException {
      showErrorDialog(context, "Email already in use");
      return false;
    } catch (_) {
      showErrorDialog(context, "Cannot update profile");
      return false;
    }
  }

  @override
  Future<void> discardChanges() async {
    _nameController.text = widget.user.name;
    _emailController.text = widget.user.email;
    _passwordController.clear();
    _confirmPasswordController.clear();
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models.dart';

import 'profile_editor.dart';
import 'profile_picture.dart';
import 'profile_fields.dart';

/// Profile page for listed users
class ProfileRegistered extends ProfileEditor {
  ProfileRegistered(User user, bool isEdit, {Key key})
      : super(user, isEdit, key: key);

  @override
  State<StatefulWidget> createState() => new _ProfileRegisteredState();
}

class _ProfileRegisteredState extends ProfileEditorState {
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: ProfilePicture(widget.isEdit),
          ),

          // Name/email
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            child: NameField(
              widget.isEdit,
              _nameController,
              _formSubmitted,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            child: EmailField(
              widget.isEdit,
              _emailController,
              _formSubmitted,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
            ),
          ),

          // Password
          if (widget.isEdit)
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 24, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 0, bottom: 12),
                    child: Text('Change password',
                        style: Theme.of(context).textTheme.subtitle2),
                  ),
                  PasswordField(
                    widget.isEdit,
                    _passwordController,
                    _formSubmitted,
                    canBeEmpty: true,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Future<bool> commitChanges() async {
    setState(() => _formSubmitted = true);
    if (!_formKey.currentState.validate()) {
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
      return true;
    } catch (err) {
      return Future.error(err);
    }
  }

  @override
  Future<void> discardChanges() async {
    _nameController.text = widget.user.name;
    _emailController.text = widget.user.email;
    _passwordController.clear();
  }
}

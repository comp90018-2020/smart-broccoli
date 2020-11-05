import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui/shared/indicators.dart';
import 'package:smart_broccoli/src/ui/shared/page.dart';

import 'profile_picture.dart';
import 'profile_fields.dart';

// Profile
class ProfilePromoting extends StatefulWidget {
  ProfilePromoting();

  @override
  State<StatefulWidget> createState() => new _ProfilePromotingState();
}

class _ProfilePromotingState extends State<ProfilePromoting> {
  // Form key
  final _formKey = GlobalKey<FormState>();
  // Used to determine Autovalidatemode
  bool _formSubmitted = false;

  final TextEditingController _nameController = new TextEditingController();
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();

  /// Whether the update has been submitted
  bool _committed = false;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPage(
      title: "Register account",
      hasDrawer: false,
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile picture
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: ProfilePicture(true),
              ),

              // Form
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                child: NameField(
                  true,
                  _nameController,
                  _formSubmitted,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                child: EmailField(
                  true,
                  _emailController,
                  _formSubmitted,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                child: PasswordField(
                  true,
                  _passwordController,
                  _formSubmitted,
                ),
              ),

              // Submit button
              Container(
                padding: EdgeInsets.only(top: 24, bottom: 16),
                width: 150,
                child: Builder(
                  builder: (context) => RaisedButton(
                    onPressed: _committed ? null : () => initPromote(context),
                    child: const Text("Submit"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Code to promote profile to a joined profile
  void initPromote(BuildContext context) async {
    setState(() => _formSubmitted = true);
    if (!_formKey.currentState.validate()) {
      return;
    }

    // Perform update
    setState(() => _committed = true);
    await Provider.of<UserProfileModel>(context, listen: false)
        .promoteUser(_emailController.text, _passwordController.text,
            _nameController.text)
        .then((_) {
      Navigator.of(context).pop();
    }).catchError((err) => showErrSnackBar(context, err.toString(), dim: true));
    setState(() => _committed = false);
  }
}

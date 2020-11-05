import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui/shared/dialog.dart';
import 'package:smart_broccoli/src/ui/shared/indicators.dart';
import 'package:smart_broccoli/src/ui/shared/page.dart';

import 'profile_picture.dart';
import 'table_items.dart';

// Profile
class ProfilePromoting extends StatefulWidget {
  ProfilePromoting();

  @override
  State<StatefulWidget> createState() => new _ProfilePromotingState();
}

class _ProfilePromotingState extends State<ProfilePromoting> {
  final TextEditingController _nameController = new TextEditingController();
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  final TextEditingController _confirmPasswordController =
      new TextEditingController();

  /// Whether the update has been submitted
  bool _committed = false;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPage(
      title: "Register account",
      hasDrawer: false,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Profile picture
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: ProfilePicture(true),
            ),
            // Form
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: TableCard(
                [
                  NameTableRow(true, _nameController),
                  EmailTableRow(true, _emailController),
                  PasswordTableRow(true, _passwordController),
                  PasswordConfirmTableRow(true, _confirmPasswordController),
                ],
              ),
            ),
            // Submit button
            Container(
              padding: EdgeInsets.only(bottom: 16),
              width: 150,
              child: RaisedButton(
                onPressed: () => initPromote(),
                child: const Text("Submit"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Code to promote profile to a joined profile
  void initPromote() async {
    if ([
      _nameController,
      _emailController,
      _passwordController,
      _confirmPasswordController
    ].any((controller) => controller.text.isEmpty))
      return await showBasicDialog(context, "All fields are required");
    if (!EmailValidator.validate(_emailController.text))
      return await showBasicDialog(context, "Invalid email");
    if (_passwordController.text.length < 8)
      return await showBasicDialog(
          context, "Password must be at least 8 characters");
    if (_passwordController.text != _confirmPasswordController.text)
      return await showBasicDialog(context, "Passwords do not match");

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

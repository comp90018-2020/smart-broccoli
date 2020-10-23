import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
      title: "Promote user",
      hasDrawer: false,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Profile picture
            ProfilePicture(true),
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
            SizedBox(
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
  void initPromote() {
    Navigator.of(context).pop();
  }
}

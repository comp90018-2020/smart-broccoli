import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_broccoli/src/ui/profile/profile_picture.dart';
import 'package:smart_broccoli/src/ui/profile/promoted_profile.dart';
import 'package:smart_broccoli/src/ui/profile/util_table.dart';
import 'package:smart_broccoli/src/ui/shared/page.dart';

// Profile
class PromotingProfile extends StatefulWidget {
  PromotingProfile();

  @override
  State<StatefulWidget> createState() => new _PromotingProfileState();
}

enum ProfileType { Promoted, Registered, Registering }

class _PromotingProfileState extends State<PromotingProfile> {
  final TextEditingController _nameController = new TextEditingController();
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  final TextEditingController _confirmPasswordController =
      new TextEditingController();

  // TODO, provider should be used to initialise image
  File _image;
  final picker = ImagePicker();

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Whether edit mode is activated
  bool _isEdit = true;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: CustomPage(
        title: "Profile",
        hasDrawer: true,
        child: SingleChildScrollView(
          child: Column(
            children: [
              ProfilePicture(_isEdit), // _changePassword()
              _formBody(),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 20,
              ),
              _submit()
            ],
          ),
        ),
      ),
    );
  }

  Widget _submit() {
    return new SizedBox(
      width: 150,
      child:
          RaisedButton(onPressed: () => initPromote(), child: Text("Submit")),
    );
  }

  // Code to promote profile to a joined profile
  void initPromote() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => PromotedProfile()),
    );
  }

  // Body
  Widget _formBody() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Material(
        type: MaterialType.card,
        elevation: 3,
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: {0: FlexColumnWidth(0.3), 1: FlexColumnWidth(0.7)},
          border: TableBorder.all(width: 0.8, color: Colors.black12),
          children: [
            // Name
            NameTableRow(_isEdit, _nameController),
            EmailTableRow(_isEdit, _emailController),
            PasswordTable(_isEdit, _passwordController),
            PasswordConfirmTable(_isEdit, _confirmPasswordController),
          ],
        ),
      ),
    );
  }
}

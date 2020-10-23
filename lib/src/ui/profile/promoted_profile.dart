import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_broccoli/src/ui/profile/profile_picture.dart';
import 'package:smart_broccoli/src/ui/profile/util_table.dart';
import 'package:smart_broccoli/src/ui/shared/page.dart';

// Profile
class PromotedProfile extends StatefulWidget {
  PromotedProfile();

  @override
  State<StatefulWidget> createState() => new _PromotedProfileState();
}

enum ProfileType { Promoted, Registered, Registering }

class _PromotedProfileState extends State<PromotedProfile> {
  final TextEditingController _nameController = new TextEditingController();
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  final TextEditingController _confirmPasswordController =
      new TextEditingController();

  // TODO, provider should be used to initialise image


  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Whether edit mode is activated
  bool _isEdit = false;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: CustomPage(
        title: "Profile",
        hasDrawer: true,

        // Save/edit
        appbarActions: [
          CupertinoButton(
            child: Text(_isEdit ? "Save" : "Edit",
                style: TextStyle(color: Colors.white)),
            onPressed: () {
              setState(() {
                _isEdit = !_isEdit;
              });
            },
          )
        ],
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
              Text(
                "Registered User",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
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

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_broccoli/src/ui/profile/profile_picture.dart';
import 'package:smart_broccoli/src/ui/profile/promoting_profile.dart';
import 'package:smart_broccoli/src/ui/profile/util_table.dart';
import 'package:smart_broccoli/src/ui/shared/page.dart';

// Profile
class RegisteredProfile extends StatefulWidget {
  // final bool isJoined;

  /// now you could have only 3 states, i.e
  /// 1. is a profile being registered?
  /// 2. is a profile being saved
  /// 3. Or is the profile already saved
  /// However I did it this way to allow for maximal flexibility

  RegisteredProfile();

  @override
  State<StatefulWidget> createState() => new _RegisteredProfileState();
}

enum ProfileType { Promoted, Registered, Registering }

class _RegisteredProfileState extends State<RegisteredProfile> {
  final TextEditingController _nameController = new TextEditingController();
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  final TextEditingController _confirmPasswordController =
      new TextEditingController();

  // TODO, provider should be used to initialise image
  File _image;
  final picker = ImagePicker();

  bool registering = false;

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
          registering
              ? Container()
              : CupertinoButton(
                  child: Text(_isEdit ? "Save" : "Edit",
                      style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    setState(() {
                      _isEdit = !_isEdit;
                    });
                  },
                ),
        ],
        child: SingleChildScrollView(
          child: Column(
            children: [
              ProfilePicture(_isEdit), // _changePassword()
              _formBody(),
              _isEdit ? Container() : _promote(),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "registering lets you login from another device and create groups",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Code here for best abstraction practices, don't inject widgets from few
  // parents above
  Widget _promote() {
    return new SizedBox(
      width: 150,
      child: RaisedButton(
          onPressed: () => initRegister(), child: Text("Register User")),
    );
  }

  // Code to promote profile to a joined profile
  void initRegister() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => PromotingProfile()),
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
          ],
        ),
      ),
    );
  }
}

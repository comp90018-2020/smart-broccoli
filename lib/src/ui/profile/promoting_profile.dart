import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
              profilePicture(), // _changePassword()
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

  // The picture
  Widget profilePicture() {
    return Stack(
      children: [
        Column(
          children: [
            // Green clip
            Container(
                color: Theme.of(context).backgroundColor,
                height: MediaQuery.of(context).size.height * 0.18),
            // White container which is half the width of the profile picture
            Container(color: Colors.white, height: 40),
          ],
        ),
        // Profile picture
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,

          /// See https://medium.com/fabcoding/adding-an-image-picker-in-a-flutter-app-pick-images-using-camera-and-gallery-photos-7f016365d856
          /// on how I implemented image changes
          child: GestureDetector(
            onTap: () {
              if (_isEdit) {
                _showPicker(context);
              }
            },
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.black12,
              child: _image != null
                  ? ClipOval(
                      child: Image.file(
                        _image,
                        fit: BoxFit.cover,
                        width: 80.0,
                        height: 80.0,
                      ),
                    )
                  : Container(
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.black12,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future _imgFromCamera() async {
    final pickedFile =
        await picker.getImage(source: ImageSource.camera, imageQuality: 50);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future _imgFromGallery() async {
    final pickedFile =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
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

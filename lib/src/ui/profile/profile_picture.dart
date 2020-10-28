// Profile
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui/shared/dialog.dart';

class ProfilePicture extends StatefulWidget {
  /// Whether picture is editable
  final bool isEdit;

  ProfilePicture(this.isEdit);

  @override
  State<StatefulWidget> createState() => new _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: [
        Column(
          children: [
            // Green clip
            Container(
                color: Theme.of(context).backgroundColor,
                height: MediaQuery.of(context).size.height * 0.18),
            // White container which is half the width of the profile picture
            Container(color: Colors.white, height: 50),
          ],
        ),
        // Profile picture
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: widget.isEdit
                ? () {
                    _showPicker(context);
                  }
                : null,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.black12,
              child: Consumer<UserProfileModel>(
                builder: (context, profile, child) => FutureBuilder(
                  future:
                      Provider.of<UserProfileModel>(context).getUserPicture(),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (!snapshot.hasData || snapshot.data == null)
                      return Container(
                        child: Icon(
                          Icons.camera_alt,
                          size: 35,
                          color: Colors.black12,
                        ),
                      );
                    return ClipOval(
                      child: Image.file(
                        File(snapshot.data),
                        fit: BoxFit.cover,
                        width: 100.0,
                        height: 100.0,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Image picker (from gallery/camera)
  Future<void> _showPicker(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text("Select upload method"),
          children: [
            SimpleDialogOption(
              child: Row(children: [
                Icon(Icons.picture_in_picture),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: const Text("From gallery"),
                )
              ]),
              onPressed: () {
                _openPictureSelector(ImageSource.gallery);
                Navigator.of(context).pop();
              },
            ),
            SimpleDialogOption(
              child: Row(children: [
                Icon(Icons.camera),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: const Text("Use camera"),
                )
              ]),
              onPressed: () {
                _openPictureSelector(ImageSource.camera);
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  // Selector (from package)
  void _openPictureSelector(ImageSource source) async {
    try {
      PickedFile pickedFile = await picker.getImage(source: source);
      if (pickedFile == null) return;
      await Provider.of<UserProfileModel>(context, listen: false)
          .updateProfilePic(await pickedFile.readAsBytes());
    } catch (err) {
      if (err.code == "photo_access_denied")
        showBasicDialog(context, "Cannot access gallery");
      else
        showBasicDialog(context, "Cannot update profile picture");
    }
  }
}

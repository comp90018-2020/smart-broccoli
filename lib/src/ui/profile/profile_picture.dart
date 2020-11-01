// Profile
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui/shared/dialog.dart';

class ProfilePicture extends StatelessWidget {
  /// Whether picture is editable
  final bool isEdit;

  ProfilePicture(this.isEdit);

  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: [
        Column(
          children: [
            // Green clip
            Container(
                color: Theme.of(context).backgroundColor,
                height: MediaQuery.of(context).size.height * 0.15),
            // White container which is half the width of the profile picture
            Container(color: Colors.white, height: 60),
          ],
        ),
        // Profile picture
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: isEdit
                ? () async {
                    ImageSource source = await showImgSrcPicker(context);
                    if (source == null) return;
                    _openPictureSelector(context, source);
                  }
                : null,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.black12,
              child: Consumer<UserProfileModel>(
                builder: (context, profile, child) => FutureBuilder(
                  future:
                      Provider.of<UserProfileModel>(context).getUserPicture(),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    return Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        if (snapshot.hasData)
                          ClipOval(
                            child: Image.file(
                              File(snapshot.data),
                              fit: BoxFit.cover,
                              width: 100.0,
                              height: 100.0,
                            ),
                          ),
                        if (!snapshot.hasData || isEdit)
                          Container(
                            width: 60,
                            height: 60,
                            child: Icon(
                              Icons.camera_alt,
                              size: 40,
                              color: Colors.black45,
                            ),
                          ),
                      ],
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

  // Selector (from package)
  void _openPictureSelector(BuildContext context, ImageSource source) async {
    final ImagePicker picker = ImagePicker();
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

var stack = new Stack(
  alignment: const Alignment(0.0, 0.0),
  children: [
    new CircleAvatar(
      backgroundImage: new AssetImage('assets/account_circle-black-24dp.svg'),
      radius: 20.0,
    ),
    new Container(
      child: Icon(
        Icons.camera_alt,
        size: 40,
        color: Colors.black12,
      ),
    )
  ],
);

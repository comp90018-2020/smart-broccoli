// Profile
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui/shared/dialog.dart';
import 'package:smart_broccoli/src/ui/shared/indicators.dart';

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
                            ),
                          ),
                        if (!snapshot.hasData || isEdit)
                          ClipOval(
                            child: Container(
                              width: 120,
                              height: double.maxFinite,
                              decoration: BoxDecoration(color: Colors.black26),
                              child: Icon(
                                Icons.camera_alt,
                                size: 40,
                                color: Colors.black87,
                              ),
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
    PickedFile pickedFile;
    try {
      pickedFile = await picker.getImage(source: source);
      if (pickedFile == null) return;
    } catch (err) {
      if (err.code == "photo_access_denied")
        return showErrSnackBar(context, "Cannot access gallery", dim: true);
      else
        return showErrSnackBar(context, err.toString(), dim: true);
    }

    // Update image
    await Provider.of<UserProfileModel>(context, listen: false)
        .updateProfilePic(await pickedFile.readAsBytes())
        .catchError((err) => showErrSnackBar(context, err.toString()));
  }
}

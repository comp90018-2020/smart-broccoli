// Profile
// References:
// https://medium.com/fabcoding/adding-an-image-picker-in-a-flutter-app-pick-images-using-camera-and-gallery-photos-7f016365d856
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePicture extends StatefulWidget {
  /// Whether picture is editable
  final bool isEdit;

  ProfilePicture(this.isEdit);

  @override
  State<StatefulWidget> createState() => new _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  File _image;
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
                        size: 35,
                        color: Colors.black12,
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
    PickedFile pickedFile = await picker.getImage(source: source);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }
}

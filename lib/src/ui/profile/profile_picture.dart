// Profile
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePicture extends StatefulWidget {
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
              if (widget.isEdit) {
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
}

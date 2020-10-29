import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

import 'package:smart_broccoli/src/ui/shared/dialog.dart';
import 'package:smart_broccoli/theme.dart';

/// Widget for pictures
///
/// Handles display and upload
class PictureCard extends StatefulWidget {
  /// The image file to display
  final String picturePath;

  /// Callback for upload
  final void Function(String) updatePicture;

  PictureCard(this.picturePath, this.updatePicture);

  @override
  State createState() => _PictureCardState();
}

class _PictureCardState extends State<PictureCard> {
  /// The image picker
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 175,
      child: Card(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            // Picture
            Container(
              width: double.maxFinite,
              child: widget.picturePath == null
                  ? Icon(Icons.insert_photo_outlined, size: 100)
                  : Image.file(File(widget.picturePath), fit: BoxFit.cover),
            ),

            // Update picture (top right)
            Positioned(
              top: 0,
              right: 6,
              child: ButtonTheme(
                minWidth: 10,
                child: RaisedButton(
                  shape: SmartBroccoliTheme.raisedButtonShape,
                  child: Icon(
                    Icons.add_a_photo,
                    size: 20,
                  ),
                  onPressed: () async {
                    ImageSource source = await showImgSrcPicker(context);
                    if (source == null) return;
                    _openPictureSelector(context, source);
                  },
                ),
              ),
            ),
          ],
        ),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        elevation: 5,
      ),
    );
  }

  void _openPictureSelector(BuildContext context, ImageSource source) async {
    PickedFile file = await picker.getImage(source: source);
    widget.updatePicture(file.path);
    Navigator.of(context).pop();
  }
}

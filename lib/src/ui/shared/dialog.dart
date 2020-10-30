import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_broccoli/src/data/quiz.dart';

Future<void> showBasicDialog(BuildContext context, String message,
    {String title = "Error"}) {
  return showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          child: Text("OK"),
          onPressed: Navigator.of(context).pop,
        ),
      ],
    ),
  );
}

Future<bool> showConfirmDialog(BuildContext context, String message,
    {String title = "Confirm"}) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          child: Text("Cancel"),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        TextButton(
          child: Text("OK"),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    ),
  );
}

Future<ImageSource> showImgSrcPicker(BuildContext context) {
  return showDialog<ImageSource>(
    context: context,
    builder: (BuildContext context) => SimpleDialog(
      title: const Text("Select upload method"),
      children: [
        SimpleDialogOption(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Icon(Icons.picture_in_picture),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: const Text("From gallery"),
                )
              ],
            ),
          ),
          onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
        ),
        SimpleDialogOption(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Icon(Icons.camera),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: const Text("Use camera"),
                )
              ],
            ),
          ),
          onPressed: () => Navigator.of(context).pop(ImageSource.camera),
        )
      ],
    ),
  );
}

Future<QuestionType> showQuestionTypePicker(BuildContext context) {
  return showDialog<QuestionType>(
    context: context,
    builder: (BuildContext context) => SimpleDialog(
      title: const Text("Select question type"),
      children: [
        SimpleDialogOption(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Icon(Icons.done),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: const Text("True/false"),
                )
              ],
            ),
          ),
          onPressed: () => Navigator.of(context).pop(QuestionType.TF),
        ),
        SimpleDialogOption(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Icon(Icons.list),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: const Text("Multiple Choice"),
                )
              ],
            ),
          ),
          onPressed: () => Navigator.of(context).pop(QuestionType.MC),
        )
      ],
    ),
  );
}

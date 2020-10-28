import 'package:flutter/material.dart';

Future<void> showBasicDialog(BuildContext context, String message,
    {String title = "Error"}) async {
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

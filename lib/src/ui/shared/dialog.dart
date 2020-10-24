import 'package:flutter/material.dart';

Future<void> showErrorDialog(BuildContext context, String message) async {
  return showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text("Error"),
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

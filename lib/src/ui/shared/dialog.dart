import 'package:flutter/material.dart';

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

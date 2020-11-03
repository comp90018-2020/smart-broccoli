import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String text,
    {String undoLabel, Function undoCall}) {
  final snackBar = SnackBar(
    content: Text(text),
    action: undoLabel == null || undoCall == null
        ? null
        : SnackBarAction(
            label: undoLabel,
            onPressed: undoCall,
          ),
  );

  // Find the Scaffold in the widget tree and use
  // it to show a SnackBar.
  Scaffold.of(context).showSnackBar(snackBar);
}

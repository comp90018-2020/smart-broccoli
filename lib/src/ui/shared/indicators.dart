import 'package:flutter/material.dart';

void showErrSnackBar(BuildContext context, String text, {bool dim = false}) {
  showSnackBar(context, text,
      backgroundColor: dim ? Colors.red[600] : Colors.red[400]);
}

void showSnackBar(BuildContext context, String text,
    {String undoLabel, Function undoCall, Color backgroundColor}) {
  final snackBar = SnackBar(
    backgroundColor: backgroundColor == null ? Colors.green : backgroundColor,
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

Widget loadingIndicator(double margin) {
  return Container(
      child: Column(
    children: [
      Padding(padding: EdgeInsets.all(margin)),
      Container(
          child: SizedBox(
              height: 25,
              width: 25,
              child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white))))
    ],
  ));
}

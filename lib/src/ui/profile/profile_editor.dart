import 'package:flutter/material.dart';

/// Interface for pages which edit the user's profile
abstract class ProfileEditor extends StatefulWidget {
  final bool isEdit;

  ProfileEditor(this.isEdit, {Key key}) : super(key: key);
}

/// Inferface for state of ProfileEditor to implement
abstract class ProfileEditorState extends State<ProfileEditor> {
  Future<bool> commitChanges();
}

import 'package:flutter/material.dart';
import 'package:smart_broccoli/src/data.dart';

/// Interface for pages which edit the user's profile
abstract class ProfileEditor extends StatefulWidget {
  final User user;
  final bool isEdit;

  ProfileEditor(this.user, this.isEdit, {Key key}) : super(key: key);
}

/// Inferface for state of ProfileEditor to implement
abstract class ProfileEditorState extends State<ProfileEditor> {
  Future<bool> commitChanges();
  Future<void> discardChanges();
}

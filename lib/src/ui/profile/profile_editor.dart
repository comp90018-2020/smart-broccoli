import 'package:flutter/material.dart';

/// Interface for pages which edit the user's profile
abstract class ProfileEditor extends StatefulWidget {}

/// Inferface for state of ProfileEditor to implement
abstract class ProfileEditorState extends State<ProfileEditor> {
  void enableEdit();
  Future<bool> commitChanges();
}

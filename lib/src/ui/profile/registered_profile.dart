import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'profile_picture.dart';
import 'table_items.dart';

/// Profile page for listed users
class RegisteredProfile extends StatefulWidget {
  /// Whether fields are in edit mode
  final bool _isEdit;

  RegisteredProfile(this._isEdit);

  @override
  State<StatefulWidget> createState() => new _RegisteredProfileState();
}

class _RegisteredProfileState extends State<RegisteredProfile> {
  final TextEditingController _nameController = new TextEditingController();
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  final TextEditingController _confirmPasswordController =
      new TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfilePicture(widget._isEdit),

        // Name/email
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Material(
            type: MaterialType.card,
            elevation: 3,
            child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: const {
                0: FlexColumnWidth(0.3),
                1: FlexColumnWidth(0.7)
              },
              border: TableBorder.all(width: 0.8, color: Colors.black12),
              children: [
                NameTableRow(widget._isEdit, _nameController),
                EmailTableRow(widget._isEdit, _emailController),
              ],
            ),
          ),
        ),

        // Password
        if (widget._isEdit)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 0, bottom: 12),
                  child: Text('Change password',
                      style: Theme.of(context).textTheme.headline6),
                ),
                Material(
                  type: MaterialType.card,
                  elevation: 3,
                  child: Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    columnWidths: const {
                      0: FlexColumnWidth(0.3),
                      1: FlexColumnWidth(0.7)
                    },
                    border: TableBorder.all(width: 0.8, color: Colors.black12),
                    children: [
                      PasswordTableRow(widget._isEdit, _passwordController),
                      PasswordConfirmTableRow(
                          widget._isEdit, _confirmPasswordController),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

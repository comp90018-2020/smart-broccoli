import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:smart_broccoli/src/models.dart';

import 'profile_picture.dart';
import 'table_items.dart';

/// Profile page for listed users
class ProfileRegistered extends StatefulWidget {
  /// Whether fields are in edit mode
  final bool _isEdit;

  final TextEditingController _nameController;
  final TextEditingController _emailController;
  final TextEditingController _passwordController;
  final TextEditingController _confirmPasswordController;

  ProfileRegistered(this._isEdit, this._nameController, this._emailController,
      this._passwordController, this._confirmPasswordController);

  @override
  State<StatefulWidget> createState() => new _ProfileRegisteredState();
}

class _ProfileRegisteredState extends State<ProfileRegistered> {
  @override
  void initState() {
    widget._nameController.text =
        Provider.of<UserProfileModel>(context, listen: false).user?.name;
    widget._emailController.text =
        Provider.of<UserProfileModel>(context, listen: false).user?.email;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfilePicture(widget._isEdit),

        // Name/email
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: TableCard(
            [
              NameTableRow(
                widget._isEdit,
                widget._nameController,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
              ),
              EmailTableRow(
                widget._isEdit,
                widget._emailController,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
              ),
            ],
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
                TableCard(
                  [
                    PasswordTableRow(
                      widget._isEdit,
                      widget._passwordController,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).nextFocus(),
                    ),
                    PasswordConfirmTableRow(
                      widget._isEdit,
                      widget._confirmPasswordController,
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui/shared/centered_page.dart';
import 'package:smart_broccoli/src/ui/shared/dialog.dart';
import 'package:smart_broccoli/src/ui/shared/snack_bar.dart';
import 'package:smart_broccoli/theme.dart';

/// Create group page
class GroupCreate extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _GroupCreateState();
}

class _GroupCreateState extends State<GroupCreate> {
  final TextEditingController controller = TextEditingController();
  bool _isTextFormFieldEmpty = true;

  /// has create button been clicked
  bool _createClicked = false;
  @override
  Widget build(BuildContext context) {
    return CenteredPage(
      title: "Create Group",
      hasDrawer: false,
      secondaryBackgroundColour: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Group name
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Group name',
                prefixIcon: Icon(Icons.people),
              ),
              onChanged: (value) =>
                  setState(() => _isTextFormFieldEmpty = value.isEmpty),
            ),
          ),
          // Button
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: RaisedButton(
                disabledTextColor:
                    SmartBroccoliColourScheme.disabledButtonTextColor,
                onPressed: _isTextFormFieldEmpty || _createClicked
                    ? null
                    : _createGroup,
                child: const Text("CREATE"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _createGroup() async {
    setState(() => _createClicked = true);
    if (controller.text == "") showSnackBar(context, 'Name required');
    try {
      await Provider.of<GroupRegistryModel>(context, listen: false)
          .createGroup(controller.text);
      Navigator.of(context).pop();
    } on GroupCreateException {
      showSnackBar(context, 'Name already in use');
    }
    setState(() => _createClicked = false);
    Navigator.of(context).pop();
  }
}

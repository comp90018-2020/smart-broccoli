import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui/shared/centered_page.dart';
import 'package:smart_broccoli/theme.dart';

/// Create group page
class GroupCreate extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _GroupCreateState();
}

class _GroupCreateState extends State<GroupCreate> {
  final TextEditingController controller = TextEditingController();
  bool _isTextFormFieldEmpty = true;

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
              onSubmitted: (_) => _createGroup(),
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
                onPressed: _isTextFormFieldEmpty ? null : _createGroup,
                child: const Text("CREATE"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _createGroup() async {
    if (controller.text == "")
      return _showUnsuccessful("Cannot create group", "Name required");
    try {
      await Provider.of<GroupRegistryModel>(context, listen: false)
          .createGroup(controller.text);
      Navigator.of(context).pop();
    } on GroupCreateException {
      _showUnsuccessful("Cannot create group", "Name already in use");
    }
  }

  void _showUnsuccessful(String title, String body) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            child: Text("OK"),
            onPressed: Navigator.of(context).pop,
          ),
        ],
      ),
    );
  }
}

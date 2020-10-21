import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
<<<<<<< HEAD:lib/src/ui/groups/group_create.dart
=======
import 'package:smart_broccoli/models.dart';
>>>>>>> 24b9919... Navigation: group list (#114):lib/src/groups/group_create.dart

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui/shared/page.dart';

/// Create group page
class GroupCreate extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _GroupCreateState();
}

class _GroupCreateState extends State<GroupCreate> {
  final TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return new CustomPage(
      title: "Create Group",
      hasDrawer: false,
      secondaryBackgroundColour: true,
      child: SingleChildScrollView(
        child: Container(
          alignment: Alignment.topCenter,
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 275),
            child: FractionallySizedBox(
              widthFactor: 0.8,
              child: Form(
                child: Column(
                  children: [
                    // Group name
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        controller: controller,
                        decoration: const InputDecoration(
                          labelText: 'Group name',
                          prefixIcon: Icon(Icons.people),
                        ),
                        onFieldSubmitted: (_) => _createGroup(),
                      ),
                    ),
                    // Button
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: RaisedButton(
                          onPressed: _createGroup,
                          child: const Text("CREATE"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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

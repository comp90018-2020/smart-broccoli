import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_broccoli/models.dart';

import '../shared/page.dart';

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
    try {
      await Provider.of<GroupRegistryModel>(context, listen: false)
          .createGroup(controller.text);
      Navigator.of(context).pop();
    } on GroupCreateException {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Cannot create group"),
          content: Text("Name already in use"),
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
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../shared/page.dart';

/// Create group page
class GroupCreate extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _GroupCreateState();
}

class _GroupCreateState extends State<GroupCreate> {
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
                        decoration: const InputDecoration(
                          labelText: 'Group name',
                          prefixIcon: Icon(Icons.people),
                        ),
                      ),
                    ),
                    // Button
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: RaisedButton(
                          onPressed: () => {},
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
}

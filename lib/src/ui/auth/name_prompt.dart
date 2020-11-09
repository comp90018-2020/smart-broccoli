import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui/shared/indicators.dart';
import 'package:smart_broccoli/theme.dart';
import 'package:smart_broccoli/src/ui/shared/centered_page.dart';

class NamePrompt extends StatefulWidget {
  @override
  _NamePromptState createState() => _NamePromptState();
}

class _NamePromptState extends State<NamePrompt> {
  /// Name field
  final TextEditingController _nameController = TextEditingController();

  bool _nameEmpty = true;

  /// whether JOIN is clicked
  bool _joinButtonClicked = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CenteredPage(
        title: "Join",
        secondaryBackgroundColour: true,
        child: Wrap(
          runSpacing: 16,
          children: [
            Center(
              child: Text(
                'To get started, enter your name',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 16,
                ),
              ),
            ),

            // name field
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person),
              ),
              keyboardType: TextInputType.name,
              onChanged: (value) => setState(() => _nameEmpty = value.isEmpty),
              onSubmitted: (value) async {
                if (value.isEmpty) return;
                _join(context);
              },
            ),

            // join button
            Container(
              width: double.infinity,
              child: Builder(
                builder: (BuildContext context) => RaisedButton(
                  child: const Text("JOIN"),
                  disabledTextColor:
                      SmartBroccoliColourScheme.disabledButtonTextColor,
                  onPressed: _nameEmpty || _joinButtonClicked
                      ? null
                      : () => _join(context),
                ),
              ),
            ),
          ],
        ),
      );

  void _join(BuildContext context) async {
    // Disable button
    setState(() => _joinButtonClicked = true);

    // Join and set name
    try {
      await Provider.of<AuthStateModel>(context, listen: false)
          .join(_nameController.text);
    } catch (err) {
      showErrSnackBar(context, err.toString());
      setState(() => _joinButtonClicked = false);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:smart_broccoli/src/models.dart';
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
                AuthStateModel auth =
                    Provider.of<AuthStateModel>(context, listen: false);
                UserProfileModel profile =
                    Provider.of<UserProfileModel>(context, listen: false);
                await auth.join();
                profile.updateUser(name: _nameController.text);
              },
            ),

            // join button
            Container(
              width: double.infinity,
              child: RaisedButton(
                child: const Text("JOIN"),
                disabledTextColor:
                    SmartBroccoliColourScheme.disabledButtonTextColor,
                onPressed: _nameEmpty
                    ? null
                    : () async {
                        AuthStateModel auth =
                            Provider.of<AuthStateModel>(context, listen: false);
                        UserProfileModel profile =
                            Provider.of<UserProfileModel>(context,
                                listen: false);
                        await auth.join();
                        profile.updateUser(name: _nameController.text);
                      },
              ),
            ),
          ],
        ),
      );
}
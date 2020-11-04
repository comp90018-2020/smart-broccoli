import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models/session_model.dart';
import 'package:smart_broccoli/src/ui/shared/dialog.dart';
import 'package:smart_broccoli/theme.dart';

import '../session/lobby.dart';

class QuizPinBox extends StatefulWidget {
  QuizPinBox({Key key}) : super(key: key);

  @override
  _QuizPinBoxState createState() => _QuizPinBoxState();
}

class _QuizPinBoxState extends State<QuizPinBox> {
  /// A pin listener
  /// listens for input by the pin listener
  final TextEditingController _pinFilter = new TextEditingController();

  Widget build(BuildContext context) {
    return Column(children: [
      // Join by pin box
      ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 80),
        child: TextField(
          controller: _pinFilter,
          textAlign: TextAlign.center,
          decoration: new InputDecoration(
            hintText: 'PIN',
            counterText: '',
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _verifyPin(context),
        ),
      ),

      // Join by pin button
      Padding(
        padding: const EdgeInsets.all(12.0),
        child: RaisedButton(
          onPressed: () => _verifyPin(context),
          shape: SmartBroccoliTheme.raisedButtonShape,
          child: Padding(
            padding: SmartBroccoliTheme.raisedButtonTextPadding,
            child: Text(
              "JOIN BY PIN",
              style: TextStyle(fontSize: 13),
            ),
          ),
        ),
      ),

      // Text for join by pin
      Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 12),
        child: FractionallySizedBox(
          widthFactor: 0.8,
          child: Text(
            "By entering PIN you can access a live quiz\n and join the group of that quiz",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    ]);
  }

  Future<void> _verifyPin(BuildContext context) async {
    try {
      await Provider.of<GameSessionModel>(context, listen: false)
          .joinSessionByPin(_pinFilter.text);
    } on SessionNotFoundException {
      showBasicDialog(context, "Invalid session PIN");
    } catch (_) {
      showBasicDialog(context, "Cannot join session");
    }
  }
}

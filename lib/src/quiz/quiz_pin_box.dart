import 'package:flutter/material.dart';
import 'package:smart_broccoli/theme.dart';

import 'lobby.dart';

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
        constraints: BoxConstraints(maxWidth: 100),
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
          onSubmitted: (_) => _verifyPin(),
        ),
      ),

      // Join by pin button
      Padding(
        padding: const EdgeInsets.all(12.0),
        child: RaisedButton(
          onPressed: _verifyPin,
          shape: SmartBroccoliTheme.raisedButtonShape,
          child: Padding(
            padding: SmartBroccoliTheme.raisedButtonTextPadding,
            child: Text(
              "JOIN BY PIN",
              style: TextStyle(fontSize: 12),
            ),
          ),
        ),
      ),

      // Text for join by pin
      Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 30.0),
        child: FractionallySizedBox(
          widthFactor: 0.8,
          child: Text(
            "By entering PIN you can access a quiz\n and join the group of that quiz",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    ]);
  }

  /// The verify pin function currently is used for debug purposes
  /// Please change this to the desired result which should be like the method
  /// Above
  void _verifyPin() {
    print(_pinFilter.text);

    // TODO remove debug code below
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => QuizLobby()),
    );
  }
}

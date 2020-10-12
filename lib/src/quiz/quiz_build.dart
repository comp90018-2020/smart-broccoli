import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_broccoli/src/quiz/widgets/card.dart';

// import 'package:smart_broccoli/src/shared/background.dart';
import 'package:smart_broccoli/src/quiz/lobby.dart';

// Build a list of quizes
class BuildQuiz extends StatefulWidget {
  BuildQuiz(this.items, {Key key}) : super(key: key);

  final List<String> items;

  @override
  State<StatefulWidget> createState() => new _BuildQuiz();
}

class _BuildQuiz extends State<BuildQuiz> {
  /// A pin listener
  /// listens for input by the pin listener
  final TextEditingController _pinFilter = new TextEditingController();

  _BuildQuiz();

  // Builder function for a list of card tiles
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: <Widget>[
            // Join by pin box
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 100),
              child: TextFormField(
                controller: _pinFilter,
                decoration: new InputDecoration(
                  labelText: 'Pin',
                  // prefixIcon: Icon(Icons.people),
                ),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
              ),
            ),

            // Join by pin button
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: RaisedButton(
                onPressed: _verifyPin,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
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

            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 290),
              child: Container(
                padding: const EdgeInsets.only(left: 25),
                child: ListView.separated(
                  // Enable Horizontal Scroll
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    return Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: QuizCard(
                          'Quiz name',
                          'Group name',
                          onTap: _quiz,
                        ));
                  },
                  // Space between the cards
                  separatorBuilder: (context, index) {
                    return Divider(indent: 1);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Take a quiz, goes to the quiz lobby which then connects you to a quiz
  /// Interface
  void _quiz() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => StartLobby()),
    );
  }

  /// The verify pin function currently is used for debug purposes
  /// Please change this to the desired result which should be like the method
  /// Above
  void _verifyPin() {
    print(_pinFilter.text);

    // TODO remove debug code below
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => StartLobby()),
    );
  }
}

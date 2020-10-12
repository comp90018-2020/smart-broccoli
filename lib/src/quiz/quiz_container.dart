import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_broccoli/src/quiz/widgets/card.dart';

// import 'package:smart_broccoli/src/shared/background.dart';
import 'package:smart_broccoli/src/quiz/lobby.dart';

// Build a list of quizes
class BuildQuiz extends StatefulWidget {
  BuildQuiz(this.header, this.items, {Key key}) : super(key: key);

  /// List of items
  final List<String> items;

  /// Header widget
  final Widget header;

  @override
  State<StatefulWidget> createState() => new _BuildQuiz();
}

class _BuildQuiz extends State<BuildQuiz> {
  _BuildQuiz();

  // Builder function for a list of card tiles
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: <Widget>[
            // Header widgets
            widget.header,

            // The list of quiz
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
}

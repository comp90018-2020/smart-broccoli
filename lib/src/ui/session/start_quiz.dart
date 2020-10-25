import 'package:flutter/material.dart';
import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/ui/shared/page.dart';
import 'package:smart_broccoli/src/ui/shared/quiz_card.dart';
import 'vertical_clip.dart';

/// Widget for Lobby
class StartQuiz extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _StartQuizState();
}

class _StartQuizState extends State<StartQuiz> {
  // Entry function
  @override
  Widget build(BuildContext context) {
    return CustomPage(
      title: 'Start Quiz',

      // Background decoration
      background: [
        Container(
          child: ClipPath(
            clipper: VerticalBackgroundClipper(),
            child: Container(
              color: Theme.of(context).colorScheme.background,
            ),
          ),
        ),
      ],

      // Body
      child: Padding(
        padding: const EdgeInsets.only(top: 8, left: 30, right: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Quiz card
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              margin: EdgeInsets.only(bottom: 12),
              child: QuizCard(
                // placeholder
                Quiz.fromJson({'title': 'Quiz title', 'groupId': 1}),
                aspectRatio: 2.3,
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Center(
                  child: Text(
                "Choose how to take this quiz",
                style: TextStyle(fontSize: 16),
              )),
            ),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: RaisedButton(
                    onPressed: () {},
                    child: Column(
                      children: [
                        Icon(
                          Icons.people,
                          size: 48,
                        ),
                        Text('With others'),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: RaisedButton(
                    onPressed: () {},
                    child: Column(
                      children: [
                        Icon(
                          Icons.person,
                          size: 48,
                        ),
                        Text('Solo'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models/quiz_collection.dart';
import 'package:smart_broccoli/src/models/session_model.dart';
import 'package:smart_broccoli/src/ui/shared/dialog.dart';
import 'package:smart_broccoli/src/ui/shared/page.dart';
import 'package:smart_broccoli/src/ui/shared/quiz_card.dart';
import 'vertical_clip.dart';

/// Widget for Lobby
class StartQuiz extends StatelessWidget {
  final int quizId;

  StartQuiz(this.quizId);

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
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 8, left: 30, right: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Quiz card
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                margin: EdgeInsets.only(bottom: 12),
                child: Consumer<QuizCollectionModel>(
                  builder: (context, collection, child) => QuizCard(
                    collection.getQuiz(quizId),
                    aspectRatio: 2.3,
                    optionsEnabled: false,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 14),
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
                      onPressed: () {
                        showBasicDialog(context, "Feature coming soon!");
                      },
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
                      onPressed: () async {
                        try {
                          await Provider.of<GameSessionModel>(context,
                                  listen: false)
                              .createSession(
                                  quizId, GameSessionType.INDIVIDUAL);
                        } catch (_) {
                          showBasicDialog(context, "Cannot start session");
                        }
                      },
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
      ),
    );
  }
}

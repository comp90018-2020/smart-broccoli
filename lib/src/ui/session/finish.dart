import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_broccoli/router.dart';
import 'package:smart_broccoli/src/base.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/models/session_model.dart';
import 'package:smart_broccoli/src/ui/shared/page.dart';
import 'package:smart_broccoli/src/ui/shared/quiz_card.dart';
import 'vertical_clip.dart';

/// Finish page for self-paced solo quizzes
class SessionFinish extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPage(
      title: 'Finished!',
      appbarLeading: IconButton(
        icon: Icon(Icons.done),
        enableFeedback: false,
        splashRadius: 20,
        onPressed: () => Provider.of<GameSessionModel>(context, listen: false)
            .pubSub
            .publish(PubSubTopic.ROUTE,
                arg: RouteArgs(action: RouteAction.POPALL_SESSION)),
      ),
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
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Consumer<GameSessionModel>(
              builder: (context, model, child) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                margin: EdgeInsets.only(bottom: 12),
                child: Consumer<QuizCollectionModel>(
                  builder: (context, collection, child) => QuizCard(
                    collection.getQuiz(model.session.quizId),
                    aspectRatio: 2.3,
                    optionsEnabled: false,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

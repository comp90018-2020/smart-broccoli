import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_broccoli/src/data.dart';

import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui/shared/page.dart';
import 'package:smart_broccoli/src/ui/shared/quiz_card.dart';
import 'package:smart_broccoli/theme.dart';

import 'vertical_clip.dart';

/// Finish page for self-paced solo quizzes
class SessionFinish extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPage(
      title: 'Finished!',
      automaticallyImplyLeading: false,
      appbarActions: [
        IconButton(
          icon: Icon(Icons.done),
          enableFeedback: false,
          splashRadius: 20,
          onPressed: () => Navigator.of(context)
              .popUntil((route) => !route.settings.name.startsWith('/session')),
        ),
      ],
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
        child: Consumer<GameSessionModel>(
          builder: (context, model, child) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                margin: EdgeInsets.only(bottom: 12),
                child: FutureBuilder(
                  future:
                      Provider.of<QuizCollectionModel>(context, listen: false)
                          .getQuiz(model.session.quizId),
                  builder:
                      (BuildContext context, AsyncSnapshot<Quiz> snapshot) =>
                          snapshot.hasData && snapshot.data != null
                              ? QuizCard(
                                  snapshot.data,
                                  aspectRatio: 2.3,
                                  optionsEnabled: false,
                                )
                              : Container(),
                ),
              ),
              if (model.points != null)
                Column(
                  children: [
                    Center(
                        child: Text('Final Score',
                            style: SmartBroccoliTheme.finalScoreCaptionStyle)),
                    Center(
                        child: Text('${model.points}',
                            style: SmartBroccoliTheme.finishScreenPointsStyle)),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}

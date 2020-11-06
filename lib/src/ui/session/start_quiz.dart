import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui/shared/dialog.dart';
import 'package:smart_broccoli/src/ui/shared/indicators.dart';
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

      child: Padding(
        padding: const EdgeInsets.only(top: 16, left: 30, right: 30),
        child: Expanded(
          child: FutureBuilder(
            future: Provider.of<QuizCollectionModel>(context, listen: false)
                .getQuiz(quizId),
            builder: (BuildContext context, AsyncSnapshot<Quiz> snapshot) =>
                snapshot.hasData && snapshot.data != null
                    ? Column(
                        children: [
                          QuizCard(
                            snapshot.data,
                            aspectRatio: 2.3,
                            optionsEnabled: false,
                          ),

                          // text and group/solo buttons
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 16.0, bottom: 8.0),
                            child: Center(
                              child: Text(
                                "Choose how to take this quiz",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: RaisedButton(
                                  onPressed: () async {
                                    try {
                                      await Provider.of<GameSessionModel>(
                                              context,
                                              listen: false)
                                          .createSession(
                                              quizId, GameSessionType.GROUP);
                                    } catch (_) {
                                      showBasicDialog(
                                          context, "Cannot start session");
                                    }
                                  },
                                  child: Column(
                                    children: [
                                      Icon(Icons.people, size: 48),
                                      Text(
                                        'With others',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: RaisedButton(
                                  onPressed: () async {
                                    await Provider.of<GameSessionModel>(context,
                                            listen: false)
                                        .createSession(
                                            quizId, GameSessionType.INDIVIDUAL)
                                        .catchError((e) => showErrSnackBar(
                                            context, e.toString()));
                                  },
                                  child: Column(
                                    children: [
                                      Icon(Icons.person, size: 48),
                                      Text(
                                        'Solo',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // text and existing session list
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 20.0, bottom: 4.0),
                            child: Align(
                              child: Text(
                                'or join an existing session',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount:
                                  _sessions(context, snapshot.data).length,
                              itemBuilder: (context, i) => Card(
                                elevation: 1.5,
                                child: ListTile(
                                  title: Text(
                                    'Session ' +
                                        _sessions(context, snapshot.data)[i]
                                            .joinCode,
                                  ),
                                  // session's unique coloured dot
                                  trailing: Icon(
                                    Icons.lens,
                                    color: _sessionColour(
                                        _sessions(context, snapshot.data)[i]),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(),
          ),
        ),
      ),
    );
  }

  List<GameSession> _sessions(BuildContext context, Quiz quiz) =>
      Provider.of<GameSessionModel>(context, listen: false)
          .getGroupSessions(quiz);

  Color _sessionColour(GameSession session) =>
      Color(int.parse('FF${session.joinCode}', radix: 16));
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui/shared/dialog.dart';
import 'package:smart_broccoli/src/ui/shared/page.dart';
import 'package:smart_broccoli/src/ui/shared/quiz_card.dart';
import 'package:smart_broccoli/theme.dart';

import 'timer.dart';
import 'vertical_clip.dart';

/// Widget for Lobby
class QuizLobby extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPage(
      title: 'Take Quiz',

      appbarLeading: IconButton(
        icon: Icon(Icons.close),
        enableFeedback: false,
        splashRadius: 20,
        onPressed: () async {
          if (!await showConfirmDialog(
              context, "You are about to quit this session")) return;
          Provider.of<GameSessionModel>(context, listen: false).quitQuiz();
        },
      ),

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
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Consumer<GameSessionModel>(
              builder: (context, model, child) => Stack(children: [
                // Quiz card
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                  margin: EdgeInsets.only(bottom: 12),
                  child: FutureBuilder(
                    future:
                        Provider.of<QuizCollectionModel>(context, listen: false)
                            .getQuiz(model.session.quizId),
                    builder: (BuildContext context,
                            AsyncSnapshot<Quiz> snapshot) =>
                        snapshot.hasData && snapshot.data != null
                            ? QuizCard(
                                snapshot.data,
                                aspectRatio: 2.3,
                                optionsEnabled: false,
                                // coloured strip if self-paced group (smart auto)
                                supplementary:
                                    model.session.type == GameSessionType.GROUP
                                        ? _colouredStrip(context, model)
                                        : null,
                              )
                            : Container(),
                  ),
                ),

                // Start button on top of card
                if (model.role == GroupRole.OWNER &&
                    model.state == SessionState.PENDING)
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: RaisedButton(
                        shape: SmartBroccoliTheme.raisedButtonShape,
                        child: Text("Start"),
                        onPressed: () {
                          Provider.of<GameSessionModel>(context, listen: false)
                              .startQuiz();
                        },
                      ),
                    ),
                  ),
              ]),
            ),

            // Padding from button to text describing (host only)
            Consumer<GameSessionModel>(
                builder: (context, model, child) => Padding(
                    padding: model.role == GroupRole.OWNER
                        ? const EdgeInsets.only(bottom: 10)
                        : const EdgeInsets.all(0))),

            // Text describing status
            Consumer<GameSessionModel>(
              builder: (context, socketModel, child) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  socketModel.waitHint,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      backgroundColor: Colors.transparent),
                ),
              ),
            ),

            Expanded(
              child: Consumer<GameSessionModel>(
                builder: (context, model, child) => Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 25),
                          child: Text(
                            'Participants',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        LobbyDivider(),
                      ],
                    ),

                    // The list of Quiz players
                    Padding(
                      padding: EdgeInsets.only(top: 26),
                      child: _quizUsers(),
                    ),

                    // Quiz countdown
                    if (model.state == SessionState.STARTING)
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.topRight,
                          child: _quizTimer(model),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Coloured strip for self-paced group (smart auto)
  Widget _colouredStrip(BuildContext context, GameSessionModel model) =>
      Container(
        decoration: BoxDecoration(
          color: Provider.of<GameSessionModel>(context, listen: false)
              .getSessionColour(model.session),
          borderRadius: BorderRadius.only(
            bottomLeft: const Radius.circular(4.0),
            bottomRight: const Radius.circular(4.0),
          ),
        ),
        height: 4,
      );

  // Timer display functionality
  Widget _quizTimer(GameSessionModel model) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 30, 0),
      child: Container(
        height: 50,
        width: 50,
        decoration: LobbyTimerBoxDecoration(),
        child: Center(
          child: TimerWidget(initTime: model.startCountDown),
        ),
      ),
    );
  }

  // Quiz users list
  Widget _quizUsers() {
    return Consumer<GameSessionModel>(
        builder: (context, model, child) => ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 8),
              shrinkWrap: true,
              itemCount: model.players.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                    dense: true,
                    // Avatar
                    leading: FutureBuilder(
                      future: model.getPeerProfilePicturePath(
                          model.players.values.toList()[index].id),
                      builder: (BuildContext context,
                              AsyncSnapshot<String> snapshot) =>
                          UserAvatar(snapshot.data, maxRadius: 20),
                    ),
                    // Name
                    title: Text(model.players.values.toList()[index].name,
                        style: SmartBroccoliTheme.listItemTextStyle));
              },
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(),
            ));
  }
}

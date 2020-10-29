import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/models/session_model.dart';
import 'package:smart_broccoli/src/ui/shared/page.dart';
import 'package:smart_broccoli/src/ui/shared/quiz_card.dart';
import 'package:smart_broccoli/theme.dart';
import 'question.dart';
import 'vertical_clip.dart';

/// Widget for Lobby
class QuizLobby extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _StartLobby();
}

class _StartLobby extends State<QuizLobby> {
  // Timer for countdown
  Timer _timer;
  // You should have a getter method here to get data from server
  int _start = 10;  // mia: get start time, needs game session model

  void startTimer1() {
    // Decrement the timer
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_start < 1) {
            //TODO after reaching this point, either:
            // 1. Call the next question activity
            // 2. Call a function in the build class
            // which creates a button for the user to move to the next class
            timer.cancel();
          } else {
            _start = _start - 1;
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // Initiate timers on start up
  @override
  void initState() {
    super.initState();
    startTimer1();
  }

  // Entry function
  @override
  Widget build(BuildContext context) {
    return CustomPage(
      title: 'Take Quiz',

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
                  child: Consumer<QuizCollectionModel>(
                    builder: (context, collection, child) => QuizCard(
                      collection.getQuiz(model.session.quizId),
                      aspectRatio: 2.3,
                      optionsEnabled: false,
                    ),
                  ),
                ),

                // Start button on top of card
                if (model.role == GroupRole.OWNER)
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: RaisedButton(
                        shape: SmartBroccoliTheme.raisedButtonShape,
                        child: Text("Start"),
                        onPressed: () => _startQuiz(),
                      ),
                    ),
                  ),
              ]),
            ),

            // Chip for group subscriptions
            
            Chip(
                label: Text('Subscribed to group'),
                avatar: Icon(Icons.check_sharp)),

            // Text describing status
            Consumer<GameSessionModel>(
              builder: (context, socketModel, child) => 
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    socketModel.waitStatement(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        backgroundColor: Colors.transparent),
                  ),
                ),
            ),

            Expanded(
              child: Stack(
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
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: _quizTimer(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Timer display functionality
  Widget _quizTimer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 30, 0),
      child: Container(
        height: 50,
        width: 50,
        decoration: LobbyTimerBoxDecoration(),
        child: Center(child: Text("$_start")),
      ),
    );
  }

  // final userList = ["A", "B", "C", "D", "E", "F", "G"]; // mia: get userList
  // Quiz users list
  Widget _quizUsers() {
    return Consumer<GameSessionModel>(
      builder: (context, socketModel, child) => 
        ListView.separated(
          padding: EdgeInsets.symmetric(vertical: 8),
          shrinkWrap: true,
          itemCount: socketModel.players.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
                dense: true,
                // Avatar
                leading: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(100))),
                // Name
                title: Text(socketModel.players.values.toList()[index].name, 
                    style: SmartBroccoliTheme.listItemTextStyle));
          },
          separatorBuilder: (BuildContext context, int index) => const Divider(),
        )
    );
  }

  void _startQuiz() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => QuizQuestion()),
    );
  }
}

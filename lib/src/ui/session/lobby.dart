import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_broccoli/theme.dart';

import 'package:smart_broccoli/src/ui/shared/page.dart';
import 'package:smart_broccoli/src/ui/shared/quiz_card.dart';
import 'question.dart';

/// Widget for Lobby
class QuizLobby extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _StartLobby();
}

class _StartLobby extends State<QuizLobby> {
  // Timer for countdown
  Timer _timer;
  // You should have a getter method here to get data from server
  int _start = 10;

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
            clipper: _BackgroundClipper(),
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
            Stack(children: [
              // Quiz card
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                margin: EdgeInsets.only(bottom: 12),
                child: QuizCard(
                  "Quiz name",
                  "Quiz group",
                  aspectRatio: 3,
                ),
              ),

              // Start button on top of card
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

            // Chip for group subscriptions
            Chip(
                label: Text('Subscribed to group'),
                avatar: Icon(Icons.check_sharp)),

            // Text describing status
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                'Waiting for host to start...',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    backgroundColor: Colors.transparent),
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

  final userList = ["A", "B", "C", "D", "E", "F", "G"];
  // Quiz users list
  Widget _quizUsers() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: 8),
      shrinkWrap: true,
      itemCount: userList.length,
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
            title: Text(userList[index],
                style: SmartBroccoliTheme.listItemTextStyle));
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }

  void _startQuiz() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => QuizQuestion()),
    );
  }
}

// Used to clip the background
class _BackgroundClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height / 4);
    path.lineTo(size.width, size.height / 4);
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

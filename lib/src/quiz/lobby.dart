import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_broccoli/src/quiz/widgets/card.dart';
import 'package:smart_broccoli/src/quiz/question.dart';
import 'package:smart_broccoli/src/quiz/widgets/users.dart';
import 'package:smart_broccoli/src/shared/page.dart';
import 'package:smart_broccoli/theme.dart';

/// The Skeleton for the start lobby
class StartLobby extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _StartLobby();
}

// Used to design the background
// Looks like a hack, but apparently this isn't a hack according to docs
class BackgroundClipper extends CustomClipper<Path> {
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

class _StartLobby extends State<StartLobby> {
  // timing functions
  Timer _timer;

  // You should have a getter method here to get data from server
  int _start = 10;

  int val = 0;

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
      background: Container(
        child: ClipPath(
          clipper: BackgroundClipper(),
          child: Container(
            color: Theme.of(context).colorScheme.background,
          ),
        ),
      ),

      // Body
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: <Widget>[
            Stack(children: [
              // Quiz card
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.4),
                  child: QuizCard(
                    "Quiz name",
                    "Quiz group",
                    aspectRatio: 2.5,
                  ),
                ),
              ),

              // Start button on top of card
              Positioned.fill(
                bottom: -8,
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

            // Text describing status
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Waiting for host to start...',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            // The divider Bar
            Stack(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Text(
                    'Participants',
                    textAlign: TextAlign.left,
                  ),
                ),
                // Orange Divider
                LobbyDivider(),
                // Timer
                _quizTimer(),
              ],
            ),

            // The list of Quiz players
            Expanded(child: QuizUsers(["A", "B", "C", "D", "E", "F", "G"])),
            // _quizPlayers(),
          ],
        ),
      ),
    );
  }

  // Timer display functionality
  Widget _quizTimer() {
    return new Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 30, 0),
        child: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration2(),
          child: Center(child: Text("$_start")),
        ),
      ),
    );
  }

  void _startQuiz() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => QuizQuestion()),
    );
  }
}

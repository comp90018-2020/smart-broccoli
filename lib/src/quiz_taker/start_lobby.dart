import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_broccoli/src/quiz_taker/quiz_question.dart';

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

    // path.moveTo(0, size.height * 0.66);
    //  path.moveTo(0, size.width*1.5);
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
  Timer _timer, _timer2;

  // You should have a getter method here to get data from server
  int _start = 50;

  // Placeholder list, the list contents should be replaced with usernames.
  List<String> propList = ["HELLO", "BOB", "MICROOSFT", "OOOOOF"];
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

  // Leaderboard referesh logic
  // Every 10 seconds, referesh and add new tiles
  void refreshLeaderboard() {
    const oneSec = const Duration(seconds: 10);
    _timer2 = new Timer.periodic(
      oneSec,
      (Timer timer2) => setState(
        () {
          if (_start < 1) {
            timer2.cancel();
          }
          val++;
          // Insert your update function here
          // For now we just add 1 item to a string list
          propList.add("General Kenobi" + val.toString());
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _timer2.cancel();
    super.dispose();
  }

  // Initiate timers on start up
  @override
  void initState() {
    super.initState();
    startTimer1();
    refreshLeaderboard();
  }

  // Entry function
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onBackground,
      // Stacks are used to stack widgets
      // Since the background is now a widget, it comes first
      body: Stack(
        children: <Widget>[
          Container(
            child: ClipPath(
              clipper: BackgroundClipper(),
              child: Container(
                color: Theme.of(context).colorScheme.background,
              ),
            ),
          ),
          // Then the rest
          Container(
            child: new Column(
              children: <Widget>[
                SizedBox(height: 50),
                _quizLogo(),
                SizedBox(height: 10),

                // The divider Bar
                Stack(
                  children: <Widget>[
                    _quizTimer(),
                    // Orange Divider
                    const Divider(
                      thickness: 5,
                      height: 50,
                      color: Colors.orangeAccent,
                    ),
                    _quizTimer(),
                  ],
                ),
                // The list of Quiz players
                _quizPlayers(),
              ],
            ),
          )
        ],
      ),
    );
  }

  // The quiz prompt with the image/question functionality
  Widget _quizLogo() {
    return Stack(
      children: <Widget>[
        Center(
          child: Container(
            height: 320,
            width: 340,
            child: Card(
              elevation: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // The image here is a placeholder, it is necessary to
                      // Provide a height and a width value
                      Image(
                          height: 150,
                          width: 340,
                          image: AssetImage('assets/images/placeholder.png')),
                      Text('Quiz Name'),
                      Text('Subtitle'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text('Live'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Column(children: <Widget>[
          //first element in column is the transparent offset
          Container(height: 290.0),
          Center(child: startButton())
        ])
      ],
    );
  }

  Widget startButton() {
    if (_start == 0) {
      return RaisedButton(
        // color: Colors,
        child: Text("Start"),
        onPressed: () => _startQuiz(),
      );
    } else {
      FlatButton(
        // color: Colors.grey,
        child: Text("Start"),
        // onPressed: () => _startQuiz(),
      );
    }
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
            decoration: new BoxDecoration(
              border: new Border.all(
                  // TODO please put this into color themes
                  color: Colors.orangeAccent,
                  width: 5.0,
                  style: BorderStyle.solid),
              // You need this line or the box will be transparent
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(child: Text("$_start")),
          ),
        ) // Text("$_start"),
        );
  }

  // Quiz players, the list of quiz users in the current lobby
  Widget _quizPlayers() {
    return Expanded(
      child: Container(
        // height: 500.0,
        child: ListView.separated(
          itemCount: propList.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              height: 50,
              child: Center(child: Text(propList[index])),
            );
          },
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
        ),
      ),
    );
  }

  void _startQuiz() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => QuizQuestion()),
    );
  }
}

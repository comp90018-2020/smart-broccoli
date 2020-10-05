import 'dart:async';

import 'package:flutter/material.dart';

class lobby extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _lobby();
}

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

class _lobby extends State<lobby> {
  Timer _timer, _timer2;
  int _start = 50;

  // Placeholder list, the list contents should be replaced with usernames.
  List<String> propList = ["HELLO", "BOB", "MICROOSFT", "OOOOOF"];
  int val = 0;

  void startTimer1() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) =>
          setState(
                () {
              if (_start < 1) {
                timer.cancel();
              } else {
                _start = _start - 1;
              }
            },
          ),
    );
  }

  void refreshLeaderboard() {
    const oneSec = const Duration(seconds: 10);
    _timer2 = new Timer.periodic(
      oneSec,
          (Timer timer2) =>
          setState(
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

  @override
  void initState() {
    startTimer1();
    refreshLeaderboard();
  }

  Widget _quizTimer() {
    return new Container(
      child: Align(
        alignment: Alignment.centerRight,
        child: Text("$_start"),
      )

    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Theme
          .of(context)
          .colorScheme
          .onBackground,
      body: Stack(
        children: <Widget>[
          Container(
              child: ClipPath(
                  clipper: BackgroundClipper(),
                  child: Container(
                    color: Theme
                        .of(context)
                        .colorScheme
                        .background,
                  ))),
          Container(
            child: new Column(
              children: <Widget>[
                // Title "UNI QUIZ"
                SizedBox(height: 50),
                _quizLogo(),
                SizedBox(height: 50),
                _quizTimer(),
                const Divider(
                  color: Colors.black,

                ),
                _quizPlayers(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _quizLogo() {
    return new Container(
      height: 320,
      width: 340,
      child: Card(
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
           // crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(

                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Image(height: 150, width: 340,image: AssetImage('assets/images/placeholder.png')),
                  Text(
                    'Quiz Name',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text('Subtitle', style: TextStyle(fontSize: 15)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text('Live', style: TextStyle(fontSize: 15)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // TODO see https://stackoverflow.com/questions/59927528/how-to-refresh-listview-builder-flutter
  Widget _quizPlayers() {
    return Expanded(
        child: Container(
            height: 500.0,
            child: ListView.separated(
              //  shrinkWrap: true,
              padding: const EdgeInsets.all(8),
              itemCount: propList.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  height: 50,
                  // color: Colors.amber[colorCodes[index]],
                  child: Center(child: Text(propList[index])),
                );
              },
              separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
            )));
  }
}

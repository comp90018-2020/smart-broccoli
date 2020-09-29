import 'dart:async';

import 'package:flutter/material.dart';


class lobby extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new  _lobby();
}

class _lobby extends State<lobby> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Container(
          child: new Column(
            children: <Widget>[
              // Title "UNI QUIZ"
              _quizLogo(),
              _quizTimer(),
              // _quizTimer(),
              // _buildTextFields(),
              // Buttons for navigation
              // _buildLiveQuiz(),
              // _buildJoinByPinButton(),
              _quizPlayers(),
            ],

          )


      ),
    );
  }

  Widget _quizLogo() {
    return new Container(
      child: new Column(
          children: <Widget>[
            new Container(
                child: Center(
                  child: Text(
                    "UNI QUIZ",
                    style: TextStyle(
                        height: 5, fontSize: 32, color: Colors.black),
                  ),
                )),
            new Container(
              // TODO GET IMAGE
              //    child: Image(image: AssetImage('graphics/background.png'))
            ),
          ]),

    );
  }

  Widget _quizPlayers() {
    return new Container(
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text("hello there"),
          );
        },
      ),
    );
  }

  Widget _quizTimer() {
    Text("$_start");
    // TODO Add decorations
  }



  Timer _timer;
  int _start = 10;

  void startTimer() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    } else {
      _timer = new Timer.periodic(
        const Duration(seconds: 1),
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
  }
}
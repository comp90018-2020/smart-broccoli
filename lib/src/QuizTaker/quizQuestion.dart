import 'dart:async';

import 'package:flutter/material.dart';

class quizQuestion extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _quizQuestion();
}

class _quizQuestion extends State<quizQuestion> {

  @override
  Widget build(BuildContext context) {

    Timer.periodic(Duration(seconds: 1), (timer) {
      startTimer();

      }
    );

    return new Scaffold(
        appBar: AppBar(
          title: Text("HELLO"),
        ),
        body: Container(
          child: new Column(
            children: <Widget>[
              // Title "UNI QUIZ"
               _quizPrompt(),
              _quizTimer(),
              // _quizTimer(),
              // _buildTextFields(),
              // Buttons for navigation
              // _buildLiveQuiz(),
              // _buildJoinByPinButton(),
              _quizAnswers(),
            ],
          ),
        ));
  }

  Widget _quizPrompt() {
    return new Column(children: <Widget>[
      new Container(
          child: Center(
        child: Text(
          "UNI QUIZ",
          style: TextStyle(height: 5, fontSize: 32, color: Colors.black),
        ),
      )),
      new Container(
          // TODO GET IMAGE
          //    child: Image(image: AssetImage('graphics/background.png'))
          )
    ]);
  }

  Widget _quizAnswers() {
    return new Container(
      child: new Column(
        children: <Widget>[

          new GridView.count(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              primary: false,
              padding: const EdgeInsets.all(20),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 2,
            children: List.generate(4, (index) {
              return Center(
                child: Text(
                  'Item $index',
                  style: Theme.of(context).textTheme.headline5,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Widget _quizTimer() {
    return new Container(
        child: Center(
          child:  Text("$_start"),
          ),
        );
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

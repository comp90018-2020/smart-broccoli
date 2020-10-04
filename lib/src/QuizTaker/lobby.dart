import 'dart:async';

import 'package:flutter/material.dart';

class lobby extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _lobby();
}

class _lobby extends State<lobby> {
  Timer _timer;
  int _start = 10;

  void startTimer1() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) => setState(
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

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    startTimer1();
  }

  Widget _quizTimer() {
    return new Container(
      child: Center(
        child: Text("$_start"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
          child: new Column(
        children: <Widget>[

          _quizLogo(),
         _quizTimer(),
          _quizPlayers(),
        ],
      )),
    );
  }

  Widget _quizLogo() {
    return new Container(
      child: new Column(children: <Widget>[
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
            ),
      ]),
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
              itemCount: 20,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  height: 50,
                  // color: Colors.amber[colorCodes[index]],
                  child: Center(child: Text('Entry $index')),
                );
              },
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(),
            )));
  }
}

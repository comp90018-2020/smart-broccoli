import 'dart:async';

import 'package:flutter/material.dart';

enum FormType {
  ShowCorrect,
  Standard,
}

/// The quiz question class displays an example of what a quiz questionare
/// would look like

class quizQuestion extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _quizQuestion();
}

class _quizQuestion extends State<quizQuestion> {
  // Global class varibles
  int state = -1;
  int _answerIndex = -1;

  // Correct answer getter
  int actual = getAnswer();
  List<String> data = getData();

  // Stateful form types
  // Standard means questions are being answeed
  // Show correct shows the correct answer

  FormType _form = FormType.Standard;

  void _formChange() async {
    setState(() {
      _form = FormType.ShowCorrect;
    });
  }

  // Timing functionalities

  Timer _timer;
  int _start = 10;

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_start < 1) {
            _formChange();
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

  // We start the timer as soon as we begin this state
  @override
  void initState() {
    startTimer();
  }

  // Entry function
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: Text("Quiz"),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.background,
          elevation: 0,
        ),
        body: SingleChildScrollView(
            child: Container(
          child: new Column(
            children: <Widget>[
              // Title "UNI QUIZ"
              _quizPrompt(),
              _quizTimer(),
              _quizAnswers(),
            ],
          ),
        )));
  }

  // The question/image being asked about
  Widget _quizPrompt() {
    return new Column(children: <Widget>[
      new Container(
        child: Text(
          "Your Question Here",
          style: TextStyle(height: 2, fontSize: 30, color: Colors.black),
        ),
      ),
      new Container(
          // TODO GET IMAGE
          child: Padding(
              padding: EdgeInsets.fromLTRB(60, 10, 60, 10),
              child: Image(image: AssetImage('assets/images/placeholder.png'))))
    ]);
  }

  // Quiz Timer Widget which displays the time and other infromation
  Widget _quizTimer() {
    if (_form == FormType.Standard) {
      return new Container(
        child: Center(
          child: Text("$_start"),
        ),
      );
    } else {
      return new Container(
        child: Center(child: determineText()),
      );
    }
    // TODO Add decorations
  }

  // The answers grid, this is changed from Wireframe designs as this is much
  // More flexiable than the previous offerings.
  Widget _quizAnswers() {
    return new Container(
      child: new Column(
        children: <Widget>[
          new GridView.count(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            primary: false,
            padding: const EdgeInsets.fromLTRB(50, 20, 50, 0),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 2,
            children: List.generate(data.length, (index) {
              return _answerTab(index);
            }),
          ),
        ],
      ),
    );
  }

  // Building upon quizAnswers, we now present the
  // features of the indivisual grid tiles
  Widget _answerTab(index) {
    if (_form == FormType.Standard) {
      return Material(
        elevation: 10,
        color: Colors.white,
        child: InkWell(
            highlightColor: Colors.pinkAccent,
            splashColor: Colors.greenAccent,
            onTap: () => updateAnswer(index),
            child: Center(
              child: Text(
                'Item $index',
                style: Theme.of(context).textTheme.headline5,
              ),
            )),
      );
    } else {
      return Material(
        elevation: 10,
        color: findColour(index),
        child: InkWell(
            highlightColor: Colors.pinkAccent,
            splashColor: Colors.greenAccent,

            //  onTap: () {},
            child: Center(
              child: Text(
                'Item $index',
                style: Theme.of(context).textTheme.headline5,
              ),
            )),
      );
    }
  }

  // Send the answer to the server
  void sendAnswer() {
    int ans = _answerIndex;
    // TODO logic code here
  }

  // Determines if the selected index value is the correct index value
  // Note indexing starts at 0 and goes from
  // left -> right -> down left -> down right
  bool isCorrectIndex(index) {
    print("Actual " + _answerIndex.toString());
    if (getAnswer() == index) {
      return true;
    }
    return false;
  }

  // TODO remove this
  bool isChosenIndex(index) {
    if (_answerIndex == index) {
      return true;
    }
    return false;
  }

  // User updated their answer, hence update accordingly
  // TODO have highlighting showing which button the user has pressed before time
  void updateAnswer(ans) async {
    print("Updated " + ans.toString());
    _answerIndex = ans;
    if (ans == getAnswer()) {
      state = 1;
    } else {
      state = 0;
    }
  }

  // See quiztimer, text tells you if you got is right or wrong
  Text determineText() {
    if (state == 1) {
      return Text("You Got it Correct!");
    }
    return Text("You Got it Incorrect!");
  }

  // Method to get the real answer from the server
  // Locked at 2 for now
  static int getAnswer() {
    return 2;
  }

  // TODO please put these colours into the Themedata configuration

  Color findColour(index) {
    if (isCorrectIndex(index)) {
      return Colors.greenAccent;
    } else if (isChosenIndex(index)) {
      return Colors.orangeAccent;
    } else {
      return Colors.redAccent;
    }
  }

  // Retrieve the data for this question from server
  // TODO implement
  static List<String> getData() {
    return ["hi", "hello", "goodbye", "yes"];
  }
}

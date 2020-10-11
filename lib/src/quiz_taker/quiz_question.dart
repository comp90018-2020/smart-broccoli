import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_broccoli/theme.dart';
import 'leader_board_lobby.dart';

enum FormType {
  ShowCorrect,
  Standard,
}

/// The quiz question class displays an example of what a quiz questionare
/// would look like

class QuizQuestion extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _QuizQuestion();
}

class _QuizQuestion extends State<QuizQuestion> {
  // Global class varibles
  int _isCorrect = -1;
  int _tappedIndex = -1;

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
  // TODO after form change transition to the next activity or leaderboard

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
    super.initState();
    startTimer();
  }

  // Entry function
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onBackground,
      appBar: AppBar(
        title: Text("Quiz"),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.background,
        actions: [_points()],
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
        ),
      ),
    );
  }

  Widget _points() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Container(
        child: Column(
          children: <Widget>[
            Text("1000"),
            Text("Points"),
          ],
        ),
      ),
    );
  }

  // The question/image being asked about
  Widget _quizPrompt() {
    return new Column(children: <Widget>[
      new Container(
        child: Text("Your Question Here"),
      ),
      new Container(
          // The image here is a placeholder
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
      return new Card(
        color: findColour(index),
        elevation: 16,
        child: InkWell(
            onTap: () => updateAnswer(index),
            child: Center(
              child: Text(
                'Item $index',
                style: Theme.of(context).textTheme.headline5,
              ),
            )),
      );
    } else {
      return new Card(
        elevation: 10,
        color: findColour(index),
        child: InkWell(
            // WARN: This ONTAP is for debug purposes only, remove from
            // Implementation
            onTap: () => next(),
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
    // int ans = _tappedIndex;
    // TODO logic code here
  }

  // Determines if the selected index value is the correct index value
  // Note indexing starts at 0 and goes from
  // left -> right -> down left -> down right
  bool isCorrectIndex(index) {
    // print("Actual " + _tappedIndex.toString());
    if (getAnswer() == index) {
      return true;
    }
    return false;
  }

  // TODO remove this
  bool isChosenIndex(index) {
    if (_tappedIndex == index) {
      return true;
    }
    return false;
  }

  // User updated their answer, hence update accordingly
  // TODO have highlighting showing which button the user has pressed before time
  void updateAnswer(ans) async {
    print("Updated " + ans.toString());
    _tappedIndex = ans;
    if (ans == getAnswer()) {
      _isCorrect = 1;
    } else {
      _isCorrect = 0;
    }
  }

  // See quiztimer, text tells you if you got is right or wrong
  Text determineText() {
    if (_isCorrect == 1) {
      return Text("You Got it Correct!");
    }
    return Text("You Got it Incorrect!");
  }

  // Method to get the real answer from the server
  // Locked at 2 for now
  static int getAnswer() {
    return 2;
  }

  Color findColour(index) {
    if (_form == FormType.ShowCorrect) {
      if (isCorrectIndex(index)) {
        return AnswerColours.correct();
      } else if (isChosenIndex(index)) {
        return AnswerColours.selected();
      } else {
        return AnswerColours.def();
      }
    } else {
      if (isChosenIndex(index)) {
        return AnswerColours.selected();
      } else {
        return AnswerColours.def();
      }
    }
  }

  // Retrieve the data for this question from server
  // TODO implement
  static List<String> getData() {
    return ["hi", "hello", "goodbye", "yes"];
  }

  // This method in the real app should check if there is another question
  // If not, move to the leaderboard
  // Otherwise move to next question
  void next() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LeaderBoardLobby()),
    );
  }
}

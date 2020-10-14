import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_broccoli/src/shared/page.dart';
import 'package:smart_broccoli/theme.dart';
import 'leaderboard.dart';

/// State of question
enum QuestionState {
  Standard,
  ShowCorrect,
}

/// Represents the quiz question page
class QuizQuestion extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _QuizQuestion();
}

class _QuizQuestion extends State<QuizQuestion> {
  int _tappedIndex = -1;

  // Correct answer getter
  int actual = 2;
  List<String> data = [
    "very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very veryvery very very very very very very very very very very very very very very very very long",
    "hello",
    "very very very very very very very very very very very very long",
    "yes"
  ];

  // State of question
  QuestionState _questionState = QuestionState.Standard;

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
            setState(() {
              _questionState = QuestionState.ShowCorrect;
            });
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
    // TODO: provider listen and store state

    return CustomPage(
      title: 'Quiz',

      // Points
      appbarActions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "1000",
                style: TextStyle(
                    color: Color(0xFFECC030),
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              Text("Points"),
            ],
          ),
        )
      ],

      // Container
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  // Question
                  Text(
                      "1. The content of question one. This is an example with image. Bla bla?",
                      style: Theme.of(context).textTheme.headline6),
                  // Question picture
                  Expanded(
                    child: FractionallySizedBox(
                      widthFactor: 0.8,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        // Replace with Container when there's no picture
                        child: Placeholder(),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      '${_start}s',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, bottom: 16.0),
                    child: Text('Flip the phone to select options',
                        style: Theme.of(context).textTheme.subtitle1),
                  ),
                ],
              ),
            ),
            Expanded(flex: 5, child: _quizAnswers())
          ],
        ),
      ),
    );
  }

  // The answers grid, this is changed from Wireframe designs as this is much
  // More flexiable than the previous offerings.
  Widget _quizAnswers() {
    return Column(
      children: [
        Expanded(child: _answerTab(0)),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _answerTab(1)),
              Expanded(child: _answerTab(2))
            ],
          ),
        ),
        Expanded(child: _answerTab(3)),
      ],
    );
  }

  // Answer selection tabs
  Widget _answerTab(int index) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          height: double.maxFinite,
          width: double.maxFinite,
          child: Text(
            'Item $index: ${data[index]}',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  // User updated their answer, hence update accordingly
  void updateAnswer(ans) async {
    print("Updated " + ans.toString());
    setState(() {
      _tappedIndex = ans;
    });
    // TODO: call model to send answer
  }

  // Determines the correct colour to display
  Color findColour(index) {
    if (_questionState == QuestionState.ShowCorrect) {
      if (index == actual) {
        return AnswerColours.correct;
      } else if (index == _tappedIndex) {
        return AnswerColours.selected;
      } else {
        return AnswerColours.normal;
      }
    } else {
      if (index == _tappedIndex) {
        return AnswerColours.selected;
      } else {
        return AnswerColours.normal;
      }
    }
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

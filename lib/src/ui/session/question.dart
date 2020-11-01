import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models/session_model.dart';
import 'package:smart_broccoli/src/ui/shared/dialog.dart';

import 'package:smart_broccoli/src/ui/shared/page.dart';
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
  GameSessionModel _sessionModel;

  List<int> _selections = [];

  // Correct answer getter
  int actual = 2;

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
    // empty answer object for this question
    Provider.of<GameSessionModel>(context, listen: false).answer = Answer(
        Provider.of<GameSessionModel>(context, listen: false).question.no);
  }

  @override
  void didChangeDependencies() {
    _sessionModel = Provider.of<GameSessionModel>(context, listen: false);
    super.didChangeDependencies();
  }

  // Entry function
  @override
  Widget build(BuildContext context) {
    return CustomPage(
      title: 'Question ${_sessionModel.question.no + 1}',

      appbarLeading: IconButton(
        icon: Icon(Icons.close),
        enableFeedback: false,
        splashRadius: 20,
        onPressed: () async {
          if (!await showConfirmDialog(
              context, "You are about to quit this session")) return;
          Provider.of<GameSessionModel>(context, listen: false).quitQuiz();
        },
      ),

      // Points
      appbarActions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '${(_sessionModel.outcome as OutcomeUser)?.record?.newPos ?? 0}',
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
                  Text("${_sessionModel.question.text}",
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
            // Answer selection boxes
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
      children: _sessionModel.question is TFQuestion
          ? [Expanded(child: _answerTab(1)), Expanded(child: _answerTab(0))]
          : [
              Expanded(child: _answerTab(0)),
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _answerTab(1)),
                    if ((_sessionModel.question as MCQuestion).options.length >
                        2)
                      Expanded(child: _answerTab(2))
                  ],
                ),
              ),
              if ((_sessionModel.question as MCQuestion).options.length > 3)
                Expanded(child: _answerTab(3)),
            ],
    );
  }

  // Answer selection tabs
  Widget _answerTab(int index) {
    return Card(
      color: findColour(index),
      child: InkWell(
        onTap: _questionState == QuestionState.Standard
            ? () => updateAnswer(index)
            : null,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
            height: double.maxFinite,
            width: double.maxFinite,
            child: Center(
              child: _sessionModel.question is TFQuestion
                  ? Text('${index == 0 ? 'False' : 'True'}',
                      style: TextStyle(fontSize: 36))
                  : Text(
                      (_sessionModel.question as MCQuestion)
                          .options[index]
                          .text,
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // User updated their answer, hence update accordingly
  void updateAnswer(int index) async {
    // TF question: only one answer can be selected
    if (_sessionModel.question is TFQuestion) {
      _sessionModel.answer.tfSelection = index == 0 ? false : true;
      _sessionModel.answerQuestion();
      setState(() {
        _selections = [index];
      });
    }

    // MC question: multiple answers may be possible
    else {
      // deselection
      if (_sessionModel.answer.mcSelection.contains(index))
        _sessionModel.answer.mcSelection.remove(index);

      // selection as long as no. selections does not exceed no. correct
      else if (_sessionModel.answer.mcSelection.length <
          (_sessionModel.question as MCQuestion).numCorrect) {
        _sessionModel.answer.mcSelection.add(index);
        // send answer if no. selections == no. correct
        if (_sessionModel.answer.mcSelection.length ==
            (_sessionModel.question as MCQuestion).numCorrect)
          _sessionModel.answerQuestion();
      }
      setState(() {
        _selections = List.from(_sessionModel.answer.mcSelection);
      });
    }
  }

  // Determines the correct colour to display
  Color findColour(index) {
    if (_questionState == QuestionState.ShowCorrect) {
      if (index == actual) return AnswerColours.correct;
      if (_selections.contains(index)) return AnswerColours.selected;
      return AnswerColours.normal;
    }

    if (_selections.contains(index)) return AnswerColours.selected;
    return AnswerColours.normal;
  }

  // This method in the real app should check if there is another question
  // If not, move to the leaderboard
  // Otherwise move to next question
  void next() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => QuizLeaderboard()),
    );
  }
}

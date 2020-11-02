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
  Timer _timer;
  int _secondsRemaining;

  void startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) => setState(() {
        if (_secondsRemaining < 1)
          timer.cancel();
        else
          --_secondsRemaining;
      }),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // initial time for question
    _secondsRemaining =
        Provider.of<GameSessionModel>(context, listen: false).time ~/ 1000;
    startTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  // Entry function
  @override
  Widget build(BuildContext context) {
    return Consumer<GameSessionModel>(
      builder: (context, model, child) => CustomPage(
        title: 'Question ${model.question.no + 1}',

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
                  '${_getPoints(model) ?? 0}',
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
                    Text("${model.question.text}",
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
                        '${_secondsRemaining}s',
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
              Expanded(flex: 5, child: _quizAnswers(model))
            ],
          ),
        ),
      ),
    );
  }

  // The answers grid, this is changed from Wireframe designs as this is much
  // More flexiable than the previous offerings.
  Widget _quizAnswers(GameSessionModel model) {
    return Column(
      children: model.question is TFQuestion
          ? [
              Expanded(child: _answerTab(model, 1)),
              Expanded(child: _answerTab(model, 0))
            ]
          : [
              Expanded(child: _answerTab(model, 0)),
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _answerTab(model, 1)),
                    if ((model.question as MCQuestion).options.length > 2)
                      Expanded(child: _answerTab(model, 2))
                  ],
                ),
              ),
              if ((model.question as MCQuestion).options.length > 3)
                Expanded(child: _answerTab(model, 3)),
            ],
    );
  }

  // Answer selection tabs
  Widget _answerTab(GameSessionModel model, int index) {
    return Card(
      color: findColour(model, index),
      child: InkWell(
        onTap: model.state == SessionState.QUESTION
            ? () => model.toggleAnswer(index)
            : null,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
            height: double.maxFinite,
            width: double.maxFinite,
            child: Center(
              child: model.question is TFQuestion
                  ? Text('${index == 0 ? 'False' : 'True'}',
                      style: TextStyle(fontSize: 36))
                  : Text(
                      (model.question as MCQuestion).options[index].text,
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  int _getPoints(GameSessionModel model) =>
      model.correctAnswer?.record?.points ??
      (model.outcome as OutcomeUser)?.record?.points;

  // // User updated their answer, hence update accordingly
  // void updateAnswer(GameSessionModel model, int index) async {

  // }

  // Determines the correct colour to display
  Color findColour(GameSessionModel model, int index) {
    if (model.question is TFQuestion) {
      // correct answer
      if (model.state == SessionState.ANSWER &&
              model.correctAnswer.answer.tfSelection &&
              index == 1 ||
          !model.correctAnswer.answer.tfSelection && index == 0)
        return AnswerColours.correct;
      // incorrect selected answer
      else if (model.answer.tfSelection != null &&
          (model.answer.tfSelection && index == 1 ||
              !model.answer.tfSelection && index == 0))
        return AnswerColours.selected;
    }
    // MC question
    else {
      // correct answer
      if (model.state == SessionState.ANSWER &&
          model.correctAnswer.answer.mcSelection.contains(index))
        return AnswerColours.correct;
      // incorrect selected answer
      if (model.answer.mcSelection != null &&
          model.answer.mcSelection.contains(index))
        return AnswerColours.selected;
    }
    // incorrect unselected answer
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

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui/shared/dialog.dart';
import 'package:smart_broccoli/src/ui/shared/page.dart';
import 'package:smart_broccoli/theme.dart';

import 'timer.dart';

/// Represents the quiz question page
class QuizQuestion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameSessionModel>(
      builder: (context, model, child) => CustomPage(
        title: 'Question ${model.question.no + 1}',

        appbarLeading: model.state == SessionState.FINISHED
            ? null
            : IconButton(
                icon: Icon(Icons.close),
                enableFeedback: false,
                splashRadius: 20,
                onPressed: () async {
                  if (model.state != SessionState.FINISHED &&
                      !await showConfirmDialog(
                          context, "You are about to quit this session"))
                    return;
                  Provider.of<GameSessionModel>(context, listen: false)
                      .quitQuiz();
                },
              ),

        automaticallyImplyLeading: false,

        // Points/next/finish button
        appbarActions: _appBarActions(context, model),

        // Container
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    // spacer if question has no pic
                    if (!model.question.hasPicture) Spacer(),
                    // question text
                    Text(
                      "${model.question.text}",
                      style: Theme.of(context).textTheme.headline6,
                      textAlign: TextAlign.center,
                    ),
                    // question picture or spacer if question has no pic
                    model.question.hasPicture
                        ? Expanded(
                            child: FractionallySizedBox(
                              widthFactor: 0.8,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                // broccoli logo placeholder while image is loading
                                child: FutureBuilder(
                                  future: Provider.of<QuizCollectionModel>(
                                          context,
                                          listen: false)
                                      .getQuestionPicturePath(model.question),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<String> snapshot) {
                                    if (!snapshot.hasData ||
                                        snapshot.data == null)
                                      return FractionallySizedBox(
                                          widthFactor: 0.8,
                                          heightFactor: 0.8,
                                          child: Image(
                                              image: AssetImage(
                                                  'assets/icon.png')));
                                    return Image.file(File(snapshot.data),
                                        fit: BoxFit.contain);
                                  },
                                ),
                              ),
                            ),
                          )
                        : Spacer(),

                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: TimerWidget(
                          initTime: model.time, style: TextStyle(fontSize: 18)),
                    ),
                    if (model.questionHint != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, bottom: 16.0),
                        child: Text(model.questionHint,
                            style: Theme.of(context).textTheme.subtitle1),
                      )
                    else
                      Container(height: 16)
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
      elevation: 4.0,
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
                      textAlign: TextAlign.center,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  /// Return the appropriate action/indicator (top right) for the user
  List<Widget> _appBarActions(BuildContext context, GameSessionModel model) => [
        if (model.state == SessionState.FINISHED &&
            model.role == GroupRole.OWNER)
          IconButton(
              onPressed: () => Navigator.of(context).popUntil(
                  (route) => !route.settings.name.startsWith('/session')),
              icon: Icon(Icons.flag))
        else if (model.state == SessionState.FINISHED)
          IconButton(
            onPressed: () =>
                Navigator.of(context).pushReplacementNamed('/session/finish'),
            icon: Icon(Icons.flag),
          )
        else if (model.state == SessionState.ANSWER &&
            model.role == GroupRole.OWNER)
          IconButton(
            onPressed: () => model.showLeaderBoard(),
            icon: Icon(Icons.arrow_forward),
          )
        else if (model.state == SessionState.OUTCOME &&
            model.role == GroupRole.OWNER)
          IconButton(
            onPressed: () => model.nextQuestion(),
            icon: Icon(Icons.arrow_forward),
          )
        else if (model.state == SessionState.ANSWER &&
            model.session.quizType == QuizType.SELF_PACED &&
            model.session.type == GameSessionType.INDIVIDUAL)
          IconButton(
            onPressed: () => model.nextQuestion(),
            icon: Icon(Icons.arrow_forward),
          )
        else if (model.role == GroupRole.MEMBER)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '${model.points ?? 0}',
                  style: TextStyle(
                      color: Color(0xFFECC030),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Text("Points"),
              ],
            ),
          )
      ];

  // Determines the correct colour to display
  Color findColour(GameSessionModel model, int index) {
    if (model.question is TFQuestion) {
      // correct answer
      if ([SessionState.ANSWER, SessionState.OUTCOME, SessionState.FINISHED]
              .contains(model.state) &&
          (model.correctAnswer.answer.tfSelection && index == 1 ||
              !model.correctAnswer.answer.tfSelection && index == 0))
        return AnswerColours.correct;
      // selected answer
      else if (model.answer.tfSelection != null &&
          (model.answer.tfSelection && index == 1 ||
              !model.answer.tfSelection && index == 0))
        return AnswerColours.selected;
    }
    // MC question
    else {
      // correct answer
      if ([SessionState.ANSWER, SessionState.OUTCOME, SessionState.FINISHED]
              .contains(model.state) &&
          model.correctAnswer.answer.mcSelection.contains(index))
        return AnswerColours.correct;
      // selected answer
      if (model.answer.mcSelection != null &&
          model.answer.mcSelection.contains(index))
        return model.answer.mcSelection.length ==
                (model.question as MCQuestion).numCorrect
            ? AnswerColours.selected
            : AnswerColours.pending;
    }
    // unselected answer
    return AnswerColours.normal;
  }
}

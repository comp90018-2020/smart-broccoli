import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models/quiz_collection.dart';
import 'package:smart_broccoli/src/models/session_model.dart';
import 'package:smart_broccoli/src/ui/session/timer.dart';
import 'package:smart_broccoli/src/ui/shared/dialog.dart';
import 'package:smart_broccoli/src/ui/shared/page.dart';
import 'package:smart_broccoli/theme.dart';

/// Represents the quiz question page
class QuizQuestion extends StatelessWidget {
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
            if (model.state != SessionState.FINISHED &&
                !await showConfirmDialog(
                    context, "You are about to quit this session")) return;
            Provider.of<GameSessionModel>(context, listen: false).quitQuiz();
          },
        ),

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
                    Text("${model.question.text}",
                        style: Theme.of(context).textTheme.headline6),
                    // question picture or spacer if question has no pic
                    model.question.hasPicture
                        ? Expanded(
                            child: FractionallySizedBox(
                              widthFactor: 0.8,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                // Replace with Container when there's no picture
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
                                        fit: BoxFit.cover);
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
                    ),
            ),
          ),
        ),
      ),
    );
  }

  /// Return the appropriate action/indicator (top right) for the user
  List<Widget> _appBarActions(BuildContext context, GameSessionModel model) => [
        // if (a) session finished; or
        //    (b) answer released; and
        //        i. user is host; or
        //        ii. session is self-paced solo
        // then show next/finish button
        if (model.state == SessionState.FINISHED ||
            model.state == SessionState.ANSWER &&
                (model.role == GroupRole.OWNER ||
                    model.session.quizType == QuizType.SELF_PACED &&
                        model.session.type == GameSessionType.INDIVIDUAL))
          IconButton(
            onPressed: () => model.role == GroupRole.OWNER
                ? model.state == SessionState.FINISHED
                    ? Navigator.of(context).popUntil(
                        (route) => !route.settings.name.startsWith('/session'))
                    : model.showLeaderBoard()
                : model.nextQuestion(),
            icon: model.state == SessionState.FINISHED
                ? Icon(Icons.flag)
                : Icon(Icons.arrow_forward),
          )

        // otherwise, show points if not host
        else if (model.role == GroupRole.MEMBER)
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
      ];

  int _getPoints(GameSessionModel model) =>
      model.correctAnswer?.record?.points ??
      (model.outcome as OutcomeUser)?.record?.points;

  // Determines the correct colour to display
  Color findColour(GameSessionModel model, int index) {
    if (model.question is TFQuestion) {
      // correct answer
      if ([SessionState.ANSWER, SessionState.OUTCOME, SessionState.FINISHED]
              .contains(model.state) &&
          (model.correctAnswer.answer.tfSelection && index == 1 ||
              !model.correctAnswer.answer.tfSelection && index == 0))
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
      if ([SessionState.ANSWER, SessionState.OUTCOME, SessionState.FINISHED]
              .contains(model.state) &&
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
}

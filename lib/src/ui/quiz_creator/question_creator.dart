import 'package:flutter/material.dart';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/ui/shared/page.dart';
import 'package:smart_broccoli/theme.dart';
import 'picture.dart';

/// Question create page
class QuestionCreate extends StatefulWidget {
  /// Question being edited
  final Question question;

  /// Question index (used to indicate)
  final int questionIndex;

  /// Delete question
  final Function(int) delete;

  QuestionCreate(
      {Key key,
      @required this.question,
      @required this.questionIndex,
      @required this.delete})
      : super(key: key);

  @override
  _QuestionCreateState createState() => _QuestionCreateState();
}

class _QuestionCreateState extends State<QuestionCreate> {
  // The cloned question
  Question question;

  // Type of question
  QuestionType questionType;

  _QuestionCreateState() {
    // Clone
    if (widget.question is MCQuestion) {
      questionType = QuestionType.MC;
      question = MCQuestion.fromJson((widget.question as MCQuestion).toJson());
    } else {
      questionType = QuestionType.TF;
      question = TFQuestion.fromJson((widget.question as TFQuestion).toJson());
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPage(
      title: 'Question',
      secondaryBackgroundColour: true,

      // Close icon
      appbarLeading: GestureDetector(
        onTap: () {
          /// TODO: confirm discard
        },
        child: Icon(Icons.close),
      ),

      // Delete and Save on AppBar
      appbarActions: <Widget>[
        IconButton(
          icon: Icon(Icons.delete),
          padding: EdgeInsets.zero,
          splashRadius: 20,
          onPressed: () {
            widget.delete(widget.questionIndex);
            Navigator.pop(context);
          },
        ),
        IconButton(
          icon: Icon(Icons.check),
          padding: EdgeInsets.zero,
          splashRadius: 20,
          onPressed: () {
            // print(widget.quiz);

            // if (questionTextController.text == "") {
            //   return _showUnsuccessful(
            //       "Cannot create question", "Question text required");
            // }
            // if (question.options.length < 2) {
            //   return _showUnsuccessful("Cannot create question",
            //       "At least two possible answers are required");
            // }

            // question.text = questionTextController.text;

            // for (var i = 0; i < _optionTextControllers.length; i++) {
            //   question.options[i].text = _optionTextControllers[i].text;
            // }

            // if (widget.passedQuestionIndex == null) {
            //   widget.quiz.questions.add(question);
            // } else {
            //   widget.quiz.questions[widget.passedQuestionIndex] = question;
            // }
            // Navigator.pop(context, widget.quiz);
          },
        ),
      ],

      child: SingleChildScrollView(
        child: Form(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Question number
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Question ${widget.questionIndex}',
                    style: new TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Question
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Question text',
                    ),
                    initialValue: question.text,
                    onChanged: (value) {
                      // Set question text
                      setState(() {
                        question.text = value;
                      });
                    },
                  ),
                ),

                // Question image
                PictureCard(null, (path) {
                  setState(() {
                    question.pendingPicturePath = path;
                  });
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Options editing for multiple choice
  List<Widget> _mcOptions(MCQuestion question) {
    return [
      // Answers heading
      Container(
        padding: EdgeInsets.only(top: 20, bottom: 4),
        child: Text(
          'Answers',
          style: new TextStyle(
            fontSize: 17.0,
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ),

      // Card container
      ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: question.options.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: _optionCard(index, question.options[index]),
          );
        },
      ),

      // Add Answer
      Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: RaisedButton(
            shape: SmartBroccoliTheme.raisedButtonShape,
            padding: EdgeInsets.all(14.0),
            child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 3,
                children: [Icon(Icons.add), Text('ADD ANSWER')]),
            onPressed: () {
              // Add choice
              setState(() => {question.options.add(QuestionOption('', false))});
            },
          ),
        ),
      )
    ];
  }

  // Creates a card for an option
  Widget _optionCard(int index, QuestionOption option) {
    return Card(
      key: ObjectKey(option),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Answer text
            TextFormField(
                initialValue: option.text,
                onChanged: (value) {
                  setState(() {
                    option.text = value;
                  });
                },
                decoration: InputDecoration(labelText: 'Answer')),

            // Bottom button action bar
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: ButtonBar(
                buttonPadding: EdgeInsets.zero,
                buttonMinWidth: 35,
                alignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Correct or not
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text('Correct: '),
                      Switch(
                        value: option.correct,
                        onChanged: (value) {
                          setState(() {
                            option.correct = value;
                          });
                        },
                      ),
                    ],
                  ),

                  // Remove
                  FlatButton(
                    visualDensity: VisualDensity.compact,
                    textColor: Colors.black54,
                    onPressed: () {
                      setState(() {
                        // Shouldn't happen
                        if (questionType != QuestionType.MC) return;
                        (question as MCQuestion).options.removeAt(index);
                      });
                    },
                    child: Icon(Icons.delete),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

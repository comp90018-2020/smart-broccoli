import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui/shared/dialog.dart';
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

  /// Save question
  final Function(int, Question) save;

  QuestionCreate(
      {Key key,
      @required this.question,
      @required this.questionIndex,
      @required this.delete,
      @required this.save})
      : super(key: key);

  @override
  _QuestionCreateState createState() => _QuestionCreateState();
}

class _QuestionCreateState extends State<QuestionCreate> {
  // The cloned question
  Question question;

  // Type of question
  QuestionType questionType;

  // Key for form widget, allows for validation
  final _formKey = GlobalKey<FormState>();

  @override
  initState() {
    super.initState();
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
        onTap: () async {
          if (questionEqual(widget.question, question) ||
              await showConfirmDialog(context,
                  "Are you sure you want to discard the question changes?",
                  title: "Discard question changes")) {
            Navigator.of(context).pop();
          }
        },
        child: Icon(Icons.close),
      ),

      // Delete and Save on AppBar
      appbarActions: <Widget>[
        IconButton(
          icon: Icon(Icons.delete),
          padding: EdgeInsets.zero,
          splashRadius: 20,
          onPressed: () async {
            // Question equal
            if (questionEqual(widget.question, question)) {
              return Navigator.pop(context);
            }

            // Delete question (parent handles)
            if (await showConfirmDialog(
                context, "Are you sure you want to delete the question?",
                title: "Delete question")) {
              widget.delete(widget.questionIndex);
              Navigator.pop(context);
            }
          },
        ),
        IconButton(
          icon: Icon(Icons.check),
          padding: EdgeInsets.zero,
          splashRadius: 20,
          onPressed: () {
            // No change
            if (questionEqual(question, widget.question)) {
              Navigator.of(context).pop();
              return;
            }

            // Check option fields
            if (!_formKey.currentState.validate()) return;

            // Text or picture
            if (question.text.isEmpty &&
                question.pictureId == null &&
                question.pendingPicturePath == null) {
              showBasicDialog(context, "Question must have body or picture");
              return;
            }

            // Correct answers
            if (question is MCQuestion &&
                (question as MCQuestion).numCorrect < 1) {
              showBasicDialog(context, "At least one option must be correct");
              return;
            }

            // Finally save
            widget.save(widget.questionIndex, question);
          },
        ),
      ],

      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
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
                    'Question ${widget.questionIndex + 1}',
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
                FutureBuilder(
                  future: getPicturePath(),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    return PictureCard(snapshot.hasData ? snapshot.data : null,
                        (path) {
                      setState(() {
                        question.pendingPicturePath = path;
                      });
                    });
                  },
                ),

                // MC options
                if (questionType == QuestionType.MC) ..._mcFields(question),

                // TF options
                if (questionType == QuestionType.TF)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 32, 8, 8),
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColorDark,
                            borderRadius: BorderRadius.circular(6)),
                        child: ToggleButtons(
                          borderRadius: BorderRadius.circular(6),
                          borderColor: Colors.transparent,
                          disabledBorderColor: Colors.transparent,
                          selectedBorderColor: Colors.transparent,
                          borderWidth: 00,
                          fillColor: Colors.white,
                          selectedColor: Colors.black,
                          color: Colors.white60,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 33),
                              child: Text('True'),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 32),
                              child: Text('False'),
                            )
                          ],
                          onPressed: (int index) {
                            setState(() {
                              (question as TFQuestion).answer = index == 0;
                            });
                          },
                          // Boolean array
                          isSelected: [
                            // True
                            (question as TFQuestion).answer,
                            // False
                            !(question as TFQuestion).answer
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Picture card
  Future<String> getPicturePath() async {
    // No image
    if (question.pendingPicturePath == null && question.pictureId == null) {
      return null;
    }
    // Updated image
    if (question.pendingPicturePath != null) return question.pendingPicturePath;
    // Image id
    return await Provider.of<QuizCollectionModel>(context, listen: false)
        .getQuestionPicture(question);
  }

  /// Options editing for multiple choice
  List<Widget> _mcFields(MCQuestion question) {
    return [
      // Answers heading
      Padding(
        padding: EdgeInsets.only(top: 20, bottom: 4),
        child: Text(
          "Answers",
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
      if (question.options.length < 4)
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
                setState(
                    () => {question.options.add(QuestionOption('', false))});
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
                validator: (val) =>
                    val.isEmpty ? "Option cannot be empty" : null,
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

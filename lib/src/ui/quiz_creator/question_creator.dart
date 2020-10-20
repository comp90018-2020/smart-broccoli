import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_broccoli/theme.dart';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/ui/shared/page.dart';
import 'picture.dart';

/// Arguments passed to question create page
class QuestionArgs {
  final int questionNumber;
  final Question question;

  QuestionArgs(this.questionNumber, this.question);
}

/// Question create page
class QuestionCreate extends StatefulWidget {
  QuestionCreate({Key key}) : super(key: key);

  @override
  _QuestionCreateState createState() => _QuestionCreateState();
}

class _QuestionCreateState extends State<QuestionCreate> {
  // Text controllers for answer
  // TODO: initial state needs to be created
  var _optionTextControllers = <TextEditingController>[];

  // The current picked file
  String picturePath;

  // Should be cloned (to allow discard of changes)
  MCQuestion question = MCQuestion(null, 'Text', []);
  int questionNumber = 1;

  @override
  void dispose() {
    for (var controller in _optionTextControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPage(
      title: 'Question',
      secondaryBackgroundColour: true,

      // Close icon
      appbarLeading: GestureDetector(
        onTap: () {},
        child: Icon(Icons.close),
      ),

      // Delete and Save on AppBar
      appbarActions: <Widget>[
        IconButton(
          icon: Icon(Icons.delete),
          padding: EdgeInsets.zero,
          splashRadius: 20,
          onPressed: () {},
        ),
        CupertinoButton(
          padding: EdgeInsets.only(right: 14),
          onPressed: () {},
          child: Text(
            'Save',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
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
                    'Question $questionNumber',
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
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Question text',
                    ),
                  ),
                ),

                // Question image
                PictureCard(picturePath, (path) {
                  setState(() {
                    picturePath = path;
                  });
                }),

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
                        // Add text controller
                        TextEditingController textController =
                            TextEditingController();
                        _optionTextControllers.add(textController);

                        // Add choice
                        setState(() =>
                            {question.options.add(QuestionOption('', false))});
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
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
                controller: _optionTextControllers[index],
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
                            question.options[index].correct = value;
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
                        question.options.removeAt(index);
                        _optionTextControllers.removeAt(index);
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui/shared/dialog.dart';
import 'package:smart_broccoli/src/ui/shared/page.dart';
import 'package:smart_broccoli/theme.dart';
import 'picture.dart';

/// Arguments for creating this widget
class QuestionArguments {
  /// Question being edited
  final Question question;

  /// Question index (used to indicate)
  final int questionIndex;

  QuestionArguments(this.question, this.questionIndex);
}

/// Return arguments used on pop
class QuestionReturnArguments {
  /// The question
  final Question question;

  /// Whether question should be deleted
  final bool delete;

  QuestionReturnArguments(this.question, {this.delete = false});
}

/// Question create page
class QuestionCreate extends StatefulWidget {
  /// Question being edited
  final Question question;

  /// Question index (used to indicate)
  final int questionIndex;

  QuestionCreate(this.question, this.questionIndex);

  @override
  _QuestionCreateState createState() => _QuestionCreateState();
}

class _QuestionCreateState extends State<QuestionCreate> {
  // The cloned question
  Question _question;

  TextEditingController _questionTextController;

  List<TextEditingController> _optionTextControllers =
      <TextEditingController>[];

  // Type of question
  QuestionType _questionType;

  // Key for form widget, allows for validation
  final _formKey = GlobalKey<FormState>();

  @override
  initState() {
    super.initState();

    // Clone
    if (widget.question is MCQuestion) {
      _questionType = QuestionType.MC;
      _question = MCQuestion.fromJson((widget.question as MCQuestion).toJson());
    } else {
      _questionType = QuestionType.TF;
      _question = TFQuestion.fromJson((widget.question as TFQuestion).toJson());
    }
    // Set question controller
    _questionTextController = TextEditingController(text: _question.text);
    // Set option controller
    if (widget.question is MCQuestion) {
      for (var option in (widget.question as MCQuestion).options) {
        _optionTextControllers.add(TextEditingController(text: option.text));
      }
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
        onTap: _close,
        child: Icon(Icons.close),
      ),

      // Delete and Save on AppBar
      appbarActions: <Widget>[
        IconButton(
            icon: Icon(Icons.delete),
            padding: EdgeInsets.zero,
            splashRadius: 20,
            onPressed: _delete),
        IconButton(
            icon: Icon(Icons.check),
            padding: EdgeInsets.zero,
            splashRadius: 20,
            onPressed: _save)
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
                    onChanged: (value) => _question.text = value,
                    controller: _questionTextController,
                  ),
                ),

                // Question image
                FutureBuilder(
                  future: _getPicturePath(),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    return PictureCard(snapshot.hasData ? snapshot.data : null,
                        (path) {
                      setState(() {
                        _question.pendingPicturePath = path;
                      });
                    });
                  },
                ),

                // MC options
                if (_questionType == QuestionType.MC) ..._mcFields(_question),

                // TF options
                if (_questionType == QuestionType.TF)
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
                              (_question as TFQuestion).answer = index == 0;
                            });
                          },
                          // Boolean array
                          isSelected: [
                            // True
                            (_question as TFQuestion).answer,
                            // False
                            !(_question as TFQuestion).answer
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
              // Add choice
              onPressed: () {
                _optionTextControllers.add(TextEditingController());
                setState(() => {
                      question.options.add(QuestionOption('', false)),
                    });
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
                controller: _optionTextControllers[index],
                onChanged: (value) {
                  option.text = value;
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
                        if (_questionType != QuestionType.MC) return;
                        (_question as MCQuestion).options.removeAt(index);
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

  /// Picture card
  Future<String> _getPicturePath() async {
    // No image
    if (_question.pendingPicturePath == null && _question.pictureId == null) {
      return null;
    }
    // Updated image
    if (_question.pendingPicturePath != null)
      return _question.pendingPicturePath;
    // Image id
    return await Provider.of<QuizCollectionModel>(context, listen: false)
        .getQuestionPicture(_question);
  }

  // Handle close icon tap
  void _close() async {
    if (widget.question == _question ||
        await showConfirmDialog(
            context, "Are you sure you want to discard changes?",
            title: "Discard question changes")) {
      Navigator.of(context).pop();
    }
  }

  // Handles delete icon tap
  void _delete() async {
    // Delete question (parent handles)
    if (await showConfirmDialog(
        context, "Are you sure you want to delete the question?",
        title: "Delete question"))
      Navigator.of(context).pop(QuestionReturnArguments(null, delete: true));
  }

  // Handles save icon tap
  void _save() {
    // Check option fields
    if (!_formKey.currentState.validate()) return;

    // Text or picture
    if (_question.text.isEmpty &&
        _question.pictureId == null &&
        _question.pendingPicturePath == null) {
      showBasicDialog(context, "Question must have body or picture");
      return;
    }

    // Correct answers
    if (_question is MCQuestion &&
        (_question as MCQuestion)
                .options
                .where((option) => option.correct)
                .length <
            1) {
      showBasicDialog(context, "At least one option must be correct");
      return;
    }

    // Options
    if (_question is MCQuestion &&
        (_question as MCQuestion).options.length <= 1) {
      showBasicDialog(context, "Must have two or more options");
      return;
    }

    // Finally save
    return Navigator.of(context).pop(QuestionReturnArguments(_question));
  }
}

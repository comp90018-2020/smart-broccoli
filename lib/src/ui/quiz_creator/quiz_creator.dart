import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';

import 'package:smart_broccoli/src/ui/shared/dialog.dart';
import 'package:smart_broccoli/src/ui/shared/page.dart';
import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/theme.dart';

import 'question_creator.dart';
import 'picture.dart';

class QuizCreate extends StatefulWidget {
  /// Group id (used for quiz creation)
  final int groupId;

  /// Quiz id (used for editing)
  final int quizId;

  QuizCreate({Key key, this.groupId, this.quizId}) : super(key: key);

  @override
  _QuizCreateState createState() => _QuizCreateState();
}

class _QuizCreateState extends State<QuizCreate> {
  /// Key for form
  final _formKey = GlobalKey<FormState>();

  Quiz quiz;

  // Provider.of<GroupRegistryModel>(context, listen: false)
  //     .refreshCreatedGroups(withMembers: true);

  TextEditingController _quizTitleController;

  @override
  void initState() {
    super.initState();

    // From group or new quiz
    if (widget.groupId != null || widget.quizId == null) {
      quiz = new Quiz("", widget.groupId, QuizType.LIVE);
    }
    // From quiz id
    // TODO:

    // Quiz title
    _quizTitleController = TextEditingController(text: quiz.title);
    _quizTitleController.addListener(() {
      quiz.title = _quizTitleController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomPage(
      title: "Quiz",
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
          onPressed: _deleteQuiz,
        ),
        IconButton(
          icon: Icon(Icons.check),
          padding: EdgeInsets.zero,
          splashRadius: 20,
          onPressed: _saveQuiz,
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
              children: [
                // Settings
                Text(
                  'Attributes',
                  style: new TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),

                // Name box
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: TextField(
                    controller: _quizTitleController,
                    decoration: InputDecoration(
                      labelText: 'Quiz name',
                    ),
                  ),
                ),

                // Picture selection
                FutureBuilder(
                  future: _getPicturePath(),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    return PictureCard(snapshot.hasData ? snapshot.data : null,
                        (path) {
                      setState(() {
                        quiz.pendingPicturePath = path;
                      });
                    });
                  },
                ),

                // Seconds selection
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: TextFormField(
                    autofocus: false,
                    readOnly: true,
                    onTap: _showTimeDialog,
                    initialValue: "${quiz.timeLimit} seconds",
                    decoration: InputDecoration(
                        labelText: 'Seconds per question',
                        prefixIcon: Icon(Icons.timer)),
                  ),
                ),

                // Group selection
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.people,
                            color: Colors.grey,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Consumer<GroupRegistryModel>(
                                builder: (context, registry, child) {
                                  return _buildGroupList(
                                      registry.createdGroups);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Quiz type
                Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  child: Column(
                    children: <Widget>[
                      RadioListTile<QuizType>(
                        dense: true,
                        title: const Text('LIVE'),
                        value: QuizType.LIVE,
                        groupValue: quiz.type,
                        onChanged: (QuizType value) {
                          setState(() {
                            quiz.type = value;
                          });
                        },
                      ),
                      RadioListTile<QuizType>(
                        dense: true,
                        title: const Text('SELF-PACED'),
                        value: QuizType.SELF_PACED,
                        groupValue: quiz.type,
                        onChanged: (QuizType value) {
                          setState(() {
                            quiz.type = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // Questions title
                Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 8),
                  child: Text(
                    'Questions',
                    style: new TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Question card
                ListView.builder(
                  scrollDirection: Axis.vertical,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: quiz.questions.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _questionCard(
                        index, quiz.questions.elementAt(index), context);
                  },
                ),

                // Add question
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: RaisedButton(
                      shape: SmartBroccoliTheme.raisedButtonShape,
                      padding: EdgeInsets.all(14.0),
                      child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 3,
                          children: [Icon(Icons.add), Text('ADD QUESTION')]),
                      onPressed: _insertQuestion,
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

  // Used to represent questions
  Widget _questionCard(int index, Question question, BuildContext context) {
    return GestureDetector(
        onTap: () => _editQuestion(index),
        child: Card(
          margin: EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.maxFinite,
                child: AspectRatio(
                  aspectRatio: 2,
                  child: Container(
                    width: double.maxFinite,
                    child: question.pictureId == null
                        ? Icon(Icons.insert_photo_outlined, size: 100)
                        : Icon(Icons.insert_photo_outlined, size: 100),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Question ${index + 1}',
                        style: Theme.of(context).textTheme.headline6),
                    Text(question.text)
                  ],
                ),
              )
            ],
          ),
        ));
  }

  /// Builds the group list dropdown
  Widget _buildGroupList(List<Group> groups) {
    return DropdownButton(
        isExpanded: true,
        items: groups
            .map((group) => DropdownMenuItem(
                  child: Text(group.name),
                  value: group.id,
                ))
            .toList(),
        onChanged: (groupId) {
          setState(() {
            quiz.groupId = groupId;
          });
        });
  }

  /// Edit question
  void _editQuestion(int index) async {
    QuestionReturnArguments returnArgs = await Navigator.of(context).pushNamed(
        "/quiz/question",
        arguments: QuestionArguments(quiz.questions[index], index));

    // Nothing returned
    if (returnArgs == null) return;

    // Delete
    setState(() {
      if (returnArgs.delete) {
        quiz.questions.removeAt(index);
      } else {
        quiz.questions.removeAt(index);
        quiz.questions.insert(index, returnArgs.question);
      }
    });
  }

  // Create question
  void _insertQuestion() async {}

  /// Picture card
  Future<String> _getPicturePath() async {
    // No image
    if (quiz.pendingPicturePath == null && quiz.pictureId == null) {
      return null;
    }
    // Updated image
    if (quiz.pendingPicturePath != null) return quiz.pendingPicturePath;
    // Image id
    return await Provider.of<QuizCollectionModel>(context, listen: false)
        .getQuizPicture(quiz);
  }

  // Time dialog
  Future _showTimeDialog() async {
    await showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return new NumberPickerDialog.integer(
              minValue: 5, maxValue: 90, initialIntegerValue: 30);
        }).then((value) {
      if (value != null && value is int) {
        setState(() {
          quiz.timeLimit = value;
        });
      }
    });
  }

  void _close() {}

  /// Save quiz
  void _saveQuiz() async {
    try {
      await Provider.of<QuizCollectionModel>(context, listen: false).saveQuiz();
      Navigator.of(context).pop();
    } catch (err) {
      showBasicDialog(context, err.toString());
    }
  }

  /// Delete quiz
  void _deleteQuiz() async {
    try {
      await Provider.of<QuizCollectionModel>(context, listen: false)
          .deleteQuiz(quiz);
      Navigator.of(context).pop();
    } on Exception catch (err) {
      showBasicDialog(context, err.toString());
    }
  }
}

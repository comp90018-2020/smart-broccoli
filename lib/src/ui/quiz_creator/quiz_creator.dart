import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/ui/shared/dialog.dart';
import 'package:smart_broccoli/src/ui/shared/page.dart';
import 'package:smart_broccoli/theme.dart';
import 'package:smart_broccoli/src/data/quiz.dart';

import '../../models.dart';
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
  final _formKey = GlobalKey<FormState>();

  Quiz quiz;

  var quizNameController;
  var timerTextController;
  String selectedGroupTitle;
  bool isDefaultGrpSelected = false;

  // Provider.of<GroupRegistryModel>(context, listen: false)
  //     .refreshCreatedGroups(withMembers: true);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPage(
      title: "Quiz",
      secondaryBackgroundColour: true,

      // Close icon
      appbarLeading: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
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
          onPressed: () async {
            try {
              await Provider.of<QuizCollectionModel>(context, listen: false)
                  .saveQuiz();
              Navigator.of(context).pop();
            } catch (err) {
              // _showUnsuccessful("Cannot save quiz", err);
            }
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
                    controller: quizNameController,
                    decoration: InputDecoration(
                      labelText: 'Quiz name',
                    ),
                  ),
                ),

                // Picture selection
                PictureCard(quiz.pendingPicturePath, (path) {
                  setState(() {
                    quiz.pendingPicturePath = path;
                  });
                }),

                // Seconds selection
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: TextField(
                    autofocus: false,
                    controller: timerTextController,
                    readOnly: true,
                    onTap: _showTimeDialog,
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
                          // Consumer<GroupRegistryModel>(
                          //   builder: (context, registry, child) {
                          //     return buildGroupList(registry.createdGroups);
                          //   },
                          // )
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
                      onPressed: () {
                        // createEditQuestion(context);
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

  /// Edit question
  void _editQuestion(int index) {}

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
          timerTextController.text = value.toString() + " seconds";
        });
      }
    });
  }

  /// Delete quiz
  void _deleteQuiz() async {
    try {
      await Provider.of<QuizCollectionModel>(context, listen: false)
          .deleteQuiz(quiz);
      Navigator.of(context).pop();
    } on Exception catch (e) {
      showBasicDialog(context, e.toString());
    }
  }
}

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
  final Quiz quiz;

  QuizCreate({Key key, this.groupId, this.quiz}) : super(key: key);

  @override
  _QuizCreateState createState() => _QuizCreateState();
}

class _QuizCreateState extends State<QuizCreate> {
  /// Key for form
  final _formKey = GlobalKey<FormState>();

  /// Quiz that is held
  Quiz _quiz;

  /// Controller for text
  TextEditingController _quizTitleController;

  @override
  void initState() {
    super.initState();

    print(widget.quiz);
    print(widget.groupId);

    /// TODO: optimise group retrieval (this retrieves quiz/members of group) repeatedly
    Provider.of<GroupRegistryModel>(context, listen: false)
        .refreshCreatedGroups();

    // From group or new quiz
    if (widget.groupId != null || widget.quiz == null)
      _quiz = new Quiz("", widget.groupId, QuizType.LIVE, timeLimit: 10);
    // From quiz id
    if (widget.quiz != null) {
      _quiz = Quiz.fromJson(widget.quiz.toJson());
    }

    // Quiz title
    _quizTitleController = TextEditingController(text: _quiz.title);
    _quizTitleController.addListener(() {
      _quiz.title = _quizTitleController.text;
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
                        _quiz.pendingPicturePath = path;
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
                    initialValue: "${_quiz.timeLimit} seconds",
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
                              padding: const EdgeInsets.only(left: 12.0),
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
                        groupValue: _quiz.type,
                        onChanged: (QuizType value) {
                          setState(() {
                            _quiz.type = value;
                          });
                        },
                      ),
                      RadioListTile<QuizType>(
                        dense: true,
                        title: const Text('SELF-PACED'),
                        value: QuizType.SELF_PACED,
                        groupValue: _quiz.type,
                        onChanged: (QuizType value) {
                          setState(() {
                            _quiz.type = value;
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
                  itemCount: _quiz.questions.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _questionCard(
                        index, _quiz.questions.elementAt(index), context);
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
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: () => _editQuestion(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.maxFinite,
              height: 175,
              child: Container(
                width: double.maxFinite,
                child: question.pictureId == null
                    ? Icon(Icons.insert_photo_outlined, size: 100)
                    : Icon(Icons.insert_photo_outlined, size: 100),
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
      ),
    );
  }

  /// Builds the group list dropdown
  Widget _buildGroupList(List<Group> groups) {
    return DropdownButton(
        isExpanded: true,
        value: _quiz.groupId,
        items: [
          DropdownMenuItem(child: Text("Select a group"), value: null),
          ...groups.map((group) => DropdownMenuItem(
                child: Text(group.name),
                value: group.id,
              ))
        ],
        onChanged: (groupId) {
          setState(() {
            _quiz.groupId = groupId;
          });
        });
  }

  /// Edit question
  void _editQuestion(int index) async {
    var returnArgs = await Navigator.of(context).pushNamed("/quiz/question",
        arguments: QuestionArguments(_quiz.questions[index], index));

    if (returnArgs is QuestionReturnArguments) {
      // No change
      if (returnArgs.question != null &&
          returnArgs.question == _quiz.questions[index]) return;
      // If saved
      setState(() {
        if (returnArgs.delete) {
          _quiz.questions.removeAt(index);
        } else {
          _quiz.questions.removeAt(index);
          _quiz.questions.insert(index, returnArgs.question);
        }
      });
    }
  }

  // Create question
  void _insertQuestion() async {
    // Show the picker
    var type = await showQuestionTypePicker(context);
    if (type == null) return;

    // Init an empty question
    Question question;
    if (type == QuestionType.MC) {
      question = MCQuestion("", []);
    } else {
      question = TFQuestion("", false);
    }

    var returnArgs = await Navigator.of(context).pushNamed("/quiz/question",
        arguments: QuestionArguments(question, _quiz.questions.length));
    // If saved
    if (returnArgs is QuestionReturnArguments && returnArgs.question != null) {
      setState(() {
        _quiz.questions.add(returnArgs.question);
      });
    }
  }

  /// Picture card
  Future<String> _getPicturePath() async {
    // No image
    if (_quiz.pendingPicturePath == null && _quiz.pictureId == null) {
      return null;
    }
    // Updated image
    if (_quiz.pendingPicturePath != null) return _quiz.pendingPicturePath;
    // Image id
    return await Provider.of<QuizCollectionModel>(context, listen: false)
        .getQuizPicture(_quiz);
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
          _quiz.timeLimit = value;
        });
      }
    });
  }

  // Exit page
  void _close() async {
    // Unsaved changes
    if (widget.quiz != _quiz) {
      if (!await showConfirmDialog(
          context, "Are you sure you want to discard changes?",
          title: "Discard quiz changes")) {
        return;
      }
    }
    Navigator.of(context).pop();
  }

  /// Save quiz
  void _saveQuiz() async {
    // No change
    if (widget.quiz != null && widget.quiz == _quiz)
      return Navigator.of(context).pop();

    try {
      await Provider.of<QuizCollectionModel>(context, listen: false)
          .saveQuiz(_quiz);
      showBasicDialog(context, "Quiz saved", title: "Success");
      Navigator.of(context).pop();
    } catch (err) {
      showBasicDialog(context, err.toString());
    }
  }

  /// Delete quiz
  void _deleteQuiz() async {
    if (!await showConfirmDialog(
        context, "Are you sure you want to delete the question?",
        title: "Delete question")) {
      return;
    }

    try {
      await Provider.of<QuizCollectionModel>(context, listen: false)
          .deleteQuiz(_quiz);
      Navigator.of(context).pop();
    } on Exception catch (err) {
      showBasicDialog(context, err.toString());
    }
  }
}

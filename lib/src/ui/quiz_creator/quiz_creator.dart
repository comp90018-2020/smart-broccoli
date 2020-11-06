import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';

import 'package:smart_broccoli/src/ui/shared/dialog.dart';
import 'package:smart_broccoli/src/ui/shared/group_dropdown.dart';
import 'package:smart_broccoli/src/ui/shared/indicators.dart';
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

  /// Whether the update has been submitted
  bool _committed = false;

  /// Quiz that is held
  Quiz _quiz;

  /// The time controller
  TextEditingController _timeController = TextEditingController();

  /// Sets the quiz that this widget holds
  void _setQuiz(Quiz quiz) {
    _quiz = Quiz.fromJson(quiz.toJson());
    _timeController.text = _getTimeString(_quiz.timeLimit);
  }

  Future<Quiz> newQuiz() {
    return Future.value(Quiz("", widget.groupId, QuizType.LIVE, timeLimit: 10));
  }

  @override
  void initState() {
    super.initState();

    /// TODO: optimise group retrieval (this retrieves quiz/members of group) repeatedly
    Provider.of<GroupRegistryModel>(context, listen: false)
        .refreshCreatedGroups();
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
        Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.delete),
            padding: EdgeInsets.zero,
            splashRadius: 20,
            onPressed: _committed ? null : _deleteQuiz,
          ),
        ),
        Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.check),
            padding: EdgeInsets.zero,
            splashRadius: 20,
            onPressed: _committed ? null : _saveQuiz,
          ),
        ),
      ],
      child: FutureBuilder(
        future: _quiz != null
            // If quiz is loaded, use loaded quiz
            ? Future.value(_quiz)
            : widget.quizId != null
                // Get quiz if quiz id
                ? Provider.of<QuizCollectionModel>(context, listen: false)
                    .getQuiz(widget.quizId, refresh: true)
                // Otherwise just create a new one
                : newQuiz(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              await showBasicDialog(context, snapshot.error.toString());
              Navigator.of(context).pop();
            });
            return Container();
          }
          if (snapshot.hasData) {
            if (_quiz == null) _setQuiz(snapshot.data);

            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                        child: TextFormField(
                          onChanged: (value) {
                            setState(() {
                              _quiz.title = value;
                            });
                          },
                          initialValue: _quiz.title,
                          decoration: InputDecoration(
                            labelText: 'Quiz name',
                          ),
                        ),
                      ),

                      // Picture selection
                      FutureBuilder(
                        future: Provider.of<QuizCollectionModel>(context)
                            .getQuizPicturePath(_quiz),
                        builder: (BuildContext context,
                            AsyncSnapshot<String> snapshot) {
                          return PictureCard(
                            snapshot.hasData ? snapshot.data : null,
                            updatePicture: (path) {
                              setState(
                                () {
                                  _quiz.pendingPicturePath = path;
                                },
                              );
                            },
                          );
                        },
                      ),

                      // Seconds selection
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: TextFormField(
                          autofocus: false,
                          readOnly: true,
                          onTap: _showTimeDialog,
                          controller: _timeController,
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
                                    padding: const EdgeInsets.only(left: 12),
                                    child: Consumer<GroupRegistryModel>(
                                      builder: (context, registry, child) {
                                        return GroupDropdown(
                                            registry.createdGroups,
                                            _quiz.groupId,
                                            onChanged: (groupId) {
                                          setState(() {
                                            _quiz.groupId = groupId;
                                          });
                                        });
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
                                children: [
                                  Icon(Icons.add),
                                  Text('ADD QUESTION')
                                ]),
                            onPressed: _insertQuestion,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }
          return Center(
              child: LoadingIndicator(EdgeInsets.symmetric(vertical: 8)));
        },
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
                child: FutureBuilder(
                    future: Provider.of<QuizCollectionModel>(context)
                        .getQuestionPicturePath(question),
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      return PictureCard(
                          snapshot.hasData ? snapshot.data : null);
                    }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Question ${index + 1}',
                      style: Theme.of(context).textTheme.headline6),
                  if (question.text.isNotEmpty) Text(question.text)
                ],
              ),
            )
          ],
        ),
      ),
    );
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

  // Time dialog
  Future _showTimeDialog() async {
    await showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return new NumberPickerDialog.integer(
              minValue: 5,
              maxValue: 90,
              initialIntegerValue: _quiz.timeLimit ?? 10);
        }).then((value) {
      if (value != null && value is int) {
        _quiz.timeLimit = value;
        _timeController.text = _getTimeString(value);
      }
    });
  }

  /// Formats a time as a string
  String _getTimeString(int time) {
    return "$time seconds";
  }

  /// Whether the quiz has been modified
  Future<bool> quizModified() async => !_quiz.partialEqual(
      await context.read<QuizCollectionModel>().getQuiz(_quiz.id));

  // Exit page
  void _close() async {
    // Quiz not loaded
    if (_quiz == null) return Navigator.of(context).pop();

    // Unsaved changes
    if (_quiz.id == null || _quiz.id != null && await quizModified()) {
      if (!await showConfirmDialog(
          context, "Are you sure you want to discard changes?",
          title: "Discard quiz changes", barrierDismissable: true)) {
        return;
      }
    }
    context.read<QuizCollectionModel>().clearSelectedQuiz();
    Navigator.of(context).pop();
  }

  /// Save quiz
  void _saveQuiz() async {
    // Quiz not loaded or no change
    if (_quiz == null || _quiz.id != null && !await quizModified()) {
      context.read<QuizCollectionModel>().clearSelectedQuiz();
      return Navigator.of(context).pop();
    }

    if (_quiz.title.isEmpty) {
      showBasicDialog(context, "Quiz name cannot be empty");
      return;
    }

    if (_quiz.groupId == null) {
      showBasicDialog(context, "Quiz must belong to a group");
      return;
    }

    setState(() => _committed = true);
    try {
      await Provider.of<QuizCollectionModel>(context, listen: false)
          .saveQuiz(_quiz);
      await showBasicDialog(context, "Quiz saved", title: "Success");
      context.read<QuizCollectionModel>().clearSelectedQuiz();
      Navigator.of(context).pop();
    } on QuizNotFoundException {
      await showBasicDialog(context, "Quiz no longer exists");
      Navigator.of(context).pop();
    } catch (err) {
      showErrSnackBar(context, err.toString());
    }
    setState(() => _committed = false);
  }

  /// Delete quiz
  void _deleteQuiz() async {
    // Quiz not loaded
    if (_quiz == null) return Navigator.of(context).pop();
    if (!await showConfirmDialog(
        context, "Are you sure you want to delete the question?",
        title: "Delete question")) {
      return;
    }

    setState(() => _committed = true);
    try {
      await Provider.of<QuizCollectionModel>(context, listen: false)
          .deleteQuiz(_quiz);
      context.read<QuizCollectionModel>().clearSelectedQuiz();
      Navigator.of(context).pop();
    } on QuizNotFoundException {
      await showBasicDialog(context, "Quiz no longer exists");
      Navigator.of(context).pop();
    } on Exception catch (err) {
      showErrSnackBar(context, err.toString());
    }
    setState(() => _committed = false);
  }
}

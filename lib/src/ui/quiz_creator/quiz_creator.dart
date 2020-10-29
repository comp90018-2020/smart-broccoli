import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import 'package:smart_broccoli/src/ui.dart';

import 'package:smart_broccoli/src/data.dart';
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

  final Quiz passedQuiz;

  QuizCreate({this.groupId, Key key, this.passedQuiz, this.quizId})
      : super(key: key);

  @override
  _QuizCreateState createState() => _QuizCreateState();
}

class _QuizCreateState extends State<QuizCreate> {
  Quiz model;
  final _formKey = GlobalKey<FormState>();
  var quizNameController;
  var timerTextController;
  String selectedGroupTitle;
  bool isDefaultGrpSelected = false;

  @override
  void initState() {
    //Editing existing quiz
    if (widget.passedQuiz != null) {
      //Cloning a quiz so that the original reference is not mutated if not saved
      Map<String, dynamic> quizJson = widget.passedQuiz.toJson();
      model = Quiz.fromJson(quizJson);
      quizNameController = TextEditingController(text: model.title);
      timerTextController =
          TextEditingController(text: model.timeLimit.toString() + " seconds");

      //Setting bytes for picture
      // if (widget.passedQuiz.pictureId != null){
      //   model.picture = widget.passedQuiz.picture;
      // }

      //Creation of a new quiz
    } else {
      // TODO: replace with cloned quiz
      model = Quiz("placeholder", 0, QuizType.LIVE);
      quizNameController = TextEditingController();
      // Text controller for seconds per question
      timerTextController = TextEditingController(text: "30 seconds");
      model.type = QuizType.LIVE;
      model.questions = new List<Question>();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<GroupRegistryModel>(context, listen: false)
        .refreshCreatedGroups(withMembers: true);

    try {} catch (e, stacktrace) {
      print(e);
      print(stacktrace);
    }

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
          onPressed: () async {
            if (await _confirmDeleteQuiz(context) == true) {
              if (model.id != null) {
                _deleteQuiz();
              } else {
                Navigator.pop(context);
              }
            }
          },
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
              _showUnsuccessful("Cannot save quiz", err);
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
                PictureCard(model.pendingPicturePath, (path) {
                  setState(() {
                    model.pendingPicturePath = path;
                  });
                }, quiz: model),

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
                          Consumer<GroupRegistryModel>(
                            builder: (context, registry, child) {
                              return buildGroupList(registry.createdGroups);
                            },
                          )
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
                        groupValue: model.type,
                        onChanged: (QuizType value) {
                          setState(() {
                            model.type = value;
                          });
                        },
                      ),
                      RadioListTile<QuizType>(
                        dense: true,
                        title: const Text('SELF-PACED'),
                        value: QuizType.SELF_PACED,
                        groupValue: model.type,
                        onChanged: (QuizType value) {
                          setState(() {
                            model.type = value;
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
                  itemCount: questionsInQuiz(),
                  itemBuilder: (BuildContext context, int index) {
                    return _questionCard(
                        index, model.questions.elementAt(index), context);
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
                        createEditQuestion(context);
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

  int questionsInQuiz() {
    if (model.questions == null) {
      return 0;
    } else if (model.questions.isEmpty) {
      return 0;
    } else if (model.questions.isNotEmpty) {
      return model.questions.length;
    }
    return 0;
  }

  createEditQuestion(BuildContext context, {int questionIndex}) async {
    fromControllersToModel();

    //Clone for quiz questions so that original copy does not get mutated in case changes are not saved
    Map<String, dynamic> quizJson = model.toJson();
    Quiz quizClone = Quiz.fromJson(quizJson);

    // Navigator returns a Future that completes after calling
    dynamic result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionCreate(
            passedQuiz: quizClone, passedQuestionIndex: questionIndex),
      ),
    );

    //Null that is returned if transition is initiated by the back button
    if (result != null) {
      setState(() {
        model = result;
      });
    }
  }

  //Transfer recent change to model
  void fromControllersToModel() {
    model.title = quizNameController.text;
  }

  // Used to represent questions
  Widget _questionCard(int index, Question question, BuildContext context) {
    var questionTextI = index + 1;

    return GestureDetector(
        onTap: () {
          createEditQuestion(context, questionIndex: index);
        },
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
                    Text('Question $questionTextI',
                        style: Theme.of(context).textTheme.headline6),
                    Text(question.text)
                  ],
                ),
              )
            ],
          ),
        ));
  }

  setPictureForCard(Question question) {
    if (question.pictureId == null) {}
  }

  Widget buildGroupList(List<Group> groups) {
    //Seeting up initial value of the group
    if (isDefaultGrpSelected == false) {
      if (widget.passedQuiz == null && widget.groupId == null) {
        model.groupId = groups[0].id;
      } else if (widget.passedQuiz == null && widget.groupId != null) {
        model.groupId = widget.groupId;
      } else if (widget.passedQuiz != null) {
        model.groupId = widget.passedQuiz.groupId;
      }

      for (var group in groups) {
        if (model.groupId == group.id) {
          selectedGroupTitle = group.name;
        }
      }

      isDefaultGrpSelected = true;
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: DropdownButton(
            isExpanded: true,
            value: selectedGroupTitle,
            items: groups.map((group) {
              return DropdownMenuItem<String>(
                value: group.name,
                child: Text(group.name),
              );
            }).toList(),
            onChanged: (String groupName) {
              setState(() {
                selectedGroupTitle = groupName;
                for (var i = 0; i < groups.length; i++) {
                  if (groupName == groups[i].name) {
                    model.groupId = groups[i].id;
                  }
                }
              });
            }),
      ),
    );
  }

  void _showUnsuccessful(String title, String body) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            child: Text("OK"),
            onPressed: Navigator.of(context).pop,
          ),
        ],
      ),
    );
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
          model.timeLimit = value;
          timerTextController.text = value.toString() + " seconds";
        });
      }
    });
  }

  void _deleteQuiz() async {
    try {
      await Provider.of<QuizCollectionModel>(context, listen: false)
          .deleteQuiz(model);
      Navigator.of(context).pop();
    } catch (e) {
      print(e);
      _showUnsuccessful("Cannot save changes in the quiz", e);
    }
  }

  Future<bool> _confirmDeleteQuiz(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Confirm quiz deletion"),
        content: Text("This cannot be undone"),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text("OK"),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}

import 'dart:developer';

import 'package:flutter/cupertino.dart';
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
import 'package:smart_broccoli/src/ui/groups/group_create.dart';

class QuizCreate extends StatefulWidget {
  final int groupId;

  QuizCreate({this.groupId, Key key}) : super(key: key);

  @override
  _QuizCreateState createState() => _QuizCreateState();
}

class _QuizCreateState extends State<QuizCreate> {


  final _formKey = GlobalKey<FormState>();

  final TextEditingController quizNameController = TextEditingController();
  // Key for form

  // Text controller for seconds per question
  var timerTextController = TextEditingController();

  // TODO: replace with cloned quiz
  Quiz model = Quiz("placeholder", 0, QuizType.LIVE);
  

  // The current picked file
  String picturePath;

  String selectedGroupTitle;

  Group selectedGroup;

  int selectedTime;

  QuizType selectedQuizType = QuizType.LIVE;
  
  

  List<Question> selectedQuestions = new List<Question>();

  @override
  Widget build(BuildContext context) {

    Provider.of<GroupRegistryModel>(context, listen: false)
        .refreshCreatedGroups(withMembers: true);

    return CustomPage(
      title: "Quiz",
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
          onPressed: () {
            _createQuiz();
          },
          child: Text(
            'Save',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
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
                PictureCard(picturePath, (path) {
                  setState(() {
                    picturePath = path;
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
                          Consumer<GroupRegistryModel>(
                            builder: (context, registry, child) {
                              return buildGroupList(registry.createdGroups);
                            }
                                ,
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
                        groupValue: selectedQuizType,
                        onChanged: (QuizType value) {
                          setState(() {
                            selectedQuizType = value;
                          });
                        },
                      ),
                      RadioListTile<QuizType>(
                        dense: true,
                        title: const Text('SELF-PACED'),
                        value: QuizType.SELF_PACED,
                        groupValue: selectedQuizType,
                        onChanged: (QuizType value) {
                          setState(() {
                            selectedQuizType = value;
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
                    return _questionCard(index, selectedQuestions.elementAt(index));
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
                        _navigateAndDisplaySelection(context);
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

  int questionsInQuiz(){

    if(selectedQuestions == null){
      return 0;
    }else if(selectedQuestions.isEmpty){
      return 0;
    }else if (selectedQuestions.isNotEmpty){
      return selectedQuestions.length;
    }
  }


  _navigateAndDisplaySelection(BuildContext context) async {
    // Navigator returns a Future that completes after calling
    dynamic result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionCreate(passedQuiz: new Quiz(quizNameController.text, selectedGroup.id, selectedQuizType, description: "No description", isActive: false, timeLimit: selectedTime, questions: selectedQuestions)),
      ),
    );

    setState(() {

     selectedGroup.id = result.groupId;
     
     selectedTime = result.timeLimit;

     selectedQuizType = result.type;
     
     selectedQuestions = result.questions;

    });
  }


  // Used to represent questions
  Widget _questionCard(int index, Question question) {
    var questionTextI = index +1;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.maxFinite,
            child: AspectRatio(aspectRatio: 2, child:
            Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: provideImage(question),
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.topCenter,
                  ),
                )
            )

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
    );
  }

  AssetImage provideImage (Question question){
    print(question.imgId);
    if(question.imgId == null){
      return AssetImage('assets/icon.png');
    }
    else{
      return AssetImage(question.imgId);
    }

  }

  Widget buildGroupList(List<Group> groups) {
    if(groups.length >0){
      selectedGroupTitle = groups[0].name;
      for (var group in groups) {
        if (group.name == groups[0].name) {
          selectedGroup = group;
        }
      }


    }
    return
      Expanded(
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
                  for (var group in groups) {
                    if (group.name == groupName) {
                      selectedGroup = group;
                    }
                  }
                });
              }),
        ),
      );
  }



  void _createQuiz() async {
    if (quizNameController.text == "")
      return _showUnsuccessful("Cannot create quiz", "Name required");
    try {
      await Provider.of<QuizCollectionModel>(context, listen: false).createQuiz(new Quiz(quizNameController.text, selectedGroup.id, selectedQuizType, description: "No description", isActive: false, timeLimit: selectedTime, questions: selectedQuestions));
      Navigator.of(context).pop();
    } on GroupCreateException {
      _showUnsuccessful("Cannot create group", "Name already in use");
    }
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
          selectedTime = value;
          timerTextController.text = value.toString() + " seconds";
        });
      }
    });
  }
}

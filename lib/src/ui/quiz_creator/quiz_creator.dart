import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/ui/shared/page.dart';
import 'package:smart_broccoli/theme.dart';

import 'picture.dart';
import 'package:smart_broccoli/src/ui/groups/group_create.dart';

class QuizCreate extends StatefulWidget {
  final int groupId;

  QuizCreate({this.groupId, Key key}) : super(key: key);

  @override
  _QuizCreateState createState() => _QuizCreateState();
}

class _QuizCreateState extends State<QuizCreate> {

  final TextEditingController controller = TextEditingController();
  // Key for form
  final _formKey = GlobalKey<FormState>();

  // Text controller for seconds per question
  var timerTextController = TextEditingController();

  // TODO: replace with cloned quiz
  Quiz model = Quiz("placeholder", 0, QuizType.LIVE);

  // The current picked file
  String picturePath;

  @override
  Widget build(BuildContext context) {
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
          onPressed: () {},
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
                    controller: controller,
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
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: DropdownButton(
                                  isExpanded: true,
                                  items: [
                                    DropdownMenuItem(child: Text('X')),
                                    DropdownMenuItem(child: Text('Y'))
                                  ],
                                  onChanged: (_) {}),
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
                  itemCount: 2,
                  itemBuilder: (BuildContext context, int index) {
                    return _questionCard(index, MCQuestion(null, 'Hello', []));
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
                        Navigator.of(context).pushNamed('/quiz/question');
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
  Widget _questionCard(int index, Question question) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.maxFinite,
            child: AspectRatio(aspectRatio: 3, child: Placeholder()),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Question $index',
                    style: Theme.of(context).textTheme.headline6),
                Text(question.text)
              ],
            ),
          )
        ],
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
}

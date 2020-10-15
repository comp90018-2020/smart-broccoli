import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_broccoli/src/quiz_creator/picture.dart';
import 'package:smart_broccoli/src/shared/page.dart';
import 'package:smart_broccoli/theme.dart';

class QuestionCreate extends StatefulWidget {
  QuestionCreate({Key key}) : super(key: key);

  @override
  _QuestionCreateState createState() => _QuestionCreateState();
}

class _QuestionCreateState extends State<QuestionCreate> {
  // Text controllers for answer
  var answerTextControllers = <TextEditingController>[];
  // ???
  var answerCards = <Card>[];

  // The current picked file
  String picturePath;

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
        CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {},
            child: Icon(Icons.delete)),
        CupertinoButton(
          padding: EdgeInsets.only(right: 14),
          onPressed: () {},
          child: Text(
            'Save',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],

      child: SingleChildScrollView(
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
                  'Question X',
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
                padding: EdgeInsets.only(top: 16),
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
                itemCount: answerCards.length,
                itemBuilder: (BuildContext context, int index) {
                  return answerCards[index];
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
                    onPressed: () =>
                        setState(() => answerCards.add(createCard())),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Card createCard() {
    var textController = TextEditingController();
    answerTextControllers.add(textController);
    return Card(
      margin: EdgeInsets.fromLTRB(12.00, 6, 12.00, 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Answer ${answerCards.length + 1}'),
          TextField(
              controller: textController,
              decoration: InputDecoration(labelText: 'Answer')),
          ButtonBar(
            alignment: MainAxisAlignment.end,
            buttonPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            children: [
              FlatButton(
                textColor: Colors.black54,
                onPressed: () {
                  answerCards.remove(this);
                  // Perform some action
                },
                child: Icon(Icons.delete),
              ),
            ],
          )
        ],
      ),
    );
  }
}

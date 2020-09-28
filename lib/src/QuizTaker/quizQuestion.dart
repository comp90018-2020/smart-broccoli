import 'package:flutter/material.dart';


class quizQuestion extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _quizQuestion();
}
class _quizQuestion extends State<quizQuestion>{
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
         body: Container(
          child: new Column(
            children: <Widget>[
              // Title "UNI QUIZ"
              _quizPrompt(),
              _quizTimer(),
              // _buildTextFields(),
              // Buttons for navigation
              // _buildLiveQuiz(),
              // _buildJoinByPinButton(),
              _quizAnswers(),
            ],
          ),
        )
    );
  }

  Widget _quizPrompt(){
    return new Column(
        children: <Widget>[

          new Container(
              child: Center(

                child: Text("UNI QUIZ",style: TextStyle(height: 5, fontSize: 32,color: Colors.white),),
              )
          ),
          new Container(
              // TODO GET IMAGE
              child: Image(image: AssetImage('graphics/background.png'))
          )
        ]
    );
  }

  Widget _quizTimer(){
    //TODO implement timer

  }

  Widget _quizAnswers(){
    return new Column(
        children: <Widget>[
          GridView.count(
          primary: false,
              padding: const EdgeInsets.all(20),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 1,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(8),
                  child: const Text("He'd have you all unravel at the"),
                  color: Colors.teal[100],
                ),
                ]
          ),
          GridView.count(
              primary: false,
              padding: const EdgeInsets.all(20),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 2,
              children: <Widget>[
              Container(
              padding: const EdgeInsets.all(8),
              child: const Text("He'd have you all unravel at the"),
              color: Colors.teal[100],
              ),
              Container(
              padding: const EdgeInsets.all(8),
              child: const Text("He'd have you all unravel at the"),
              color: Colors.teal[100],
              ),
            ]
        ),
          GridView.count(
              primary: false,
              padding: const EdgeInsets.all(20),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 1,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(8),
                  child: const Text("He'd have you all unravel at the"),
                  color: Colors.teal[100],
                )
              ]
          )
    ]
    );
  }
}

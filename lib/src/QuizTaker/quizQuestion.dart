import 'dart:async';

import 'package:flutter/material.dart';

enum FormType {
  ShowCorrect,
  Standard,
}



class quizQuestion extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _quizQuestion();
}

class _quizQuestion extends State<quizQuestion> {
  int _answerIndex = -1;

  FormType _form = FormType.Standard;


  void _formChange () async {
    setState(() {
     _form = FormType.ShowCorrect;
    });
  }


  Timer _timer;
  int _start = 10;



  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) => setState(
            () {
          if (_start < 1) {
            timer.cancel();
          } else {
            _start = _start - 1;
          }
        },
      ),
    );
  }



  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    startTimer();
  }



  @override
  Widget build(BuildContext context) {


    return new Scaffold(
        appBar: AppBar(
          title: Text("HELLO"),
        ),
        body: Container(
          child: new Column(
            children: <Widget>[
              // Title "UNI QUIZ"
               _quizPrompt(),
              _quizTimer(),
              // _quizTimer(),
              // _buildTextFields(),
              // Buttons for navigation
              // _buildLiveQuiz(),
              // _buildJoinByPinButton(),
              _quizAnswers(),
            ],
          ),
        ));
  }

  Widget _quizPrompt() {
    return new Column(children: <Widget>[
      new Container(
          child: Center(
        child: Text(
          "UNI QUIZ",
          style: TextStyle(height: 5, fontSize: 32, color: Colors.black),
        ),
      )),
      new Container(
          // TODO GET IMAGE
          child: Image(image: AssetImage('assets/images/placeholder.png'))
          )
    ]);
  }

  Widget _quizAnswers() {
    return new Container(
      child: new Column(
        children: <Widget>[

          new GridView.count(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              primary: false,
              padding: const EdgeInsets.all(20),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 2,
            children: List.generate(4, (index) {

              return _answerTab(index);

            }),
          ),
        ],
      ),
    );
  }

  Widget _answerTab(index){
    int correct = isCorrectIndex(index);
    
    if(_form == FormType.Standard) {
      return Material(
        color: Colors.white,
        child: InkWell(
            highlightColor: Colors.pinkAccent,
            splashColor: Colors.greenAccent,

            onTap: () => updateAnswer(index),
            child: Center(
              child: Text(
                'Item $index',
                style: Theme
                    .of(context)
                    .textTheme
                    .headline5,
              ),
            )
        ),
      );
    }
    else{
      Color col = Colors.white;
      if(correct==1){
        Color col = Colors.orange;
      }
      return Material(
          color: col,
          child: InkWell(
          highlightColor: Colors.pinkAccent,
          splashColor: Colors.greenAccent,

        //  onTap: () {},
    child: Center(
    child: Text(
    'Item $index',
    style: Theme
        .of(context)
        .textTheme
        .headline5,
    ),
    )
    ),
    );
      
    }

  }

  void sendAnswer(){
    int ans = _answerIndex;
    // TODO logic code here
  }

  Widget _quizTimer() {
    return new Container(
        child: Center(
          child:  Text("$_start"),
          ),
        );
    // TODO Add decorations
  }

  int isCorrectIndex(index) {
    // TODO add stuff

  }
  void updateAnswer(ans) async {
    _answerIndex = ans;

  }

}

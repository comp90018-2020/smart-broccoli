
import 'package:flutter/material.dart';


class quizMaker extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _quizMakerState();
}

enum quizType {
  All,
  Live,
  SelfPaced
}


class _quizMakerState extends State<quizMaker> {

  final TextEditingController _pinFilter = new TextEditingController();

  String _pin = "";

  void _pinListen() {
    if (_pinFilter.text.isEmpty) {
      _pin = "";
    } else {
      _pin = _pinFilter.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: _buildTextFields());
  }

  Widget _buildTextFields() {
    return new Container(
      child: new Column(
        children: <Widget>[
          // Title "UNI QUIZ"
          _SwitchButton(),
          // _buildTextFields(),
          // Buttons for navigation
         // _buildLiveQuiz(),
          // _buildJoinByPinButton(),
          _buildQuizList(),
        ],
      ),
    );
  }

  Widget _SwitchButton(){
    return new Container(
        child: new Row(
            children: <Widget>[
          new Container(
            child: new ButtonTheme(
              buttonColor: Colors.white,
              child: RaisedButton(
                onPressed: _formChange,
                //  onPressed: _loginPressed, // TODO CHANGE
                child: Text("Placeholder Switch"),
              ),
            ),
          ),
          new Container(
            child: new ButtonTheme(
              buttonColor: Colors.white,
              child: RaisedButton(
                onPressed: _formChange,
                //  onPressed: _loginPressed, // TODO CHANGE
                child: Text("Placeholder Switch"),
              ),
            ),
          ),
          new Container(
            child: new ButtonTheme(
              buttonColor: Colors.white,
              child: RaisedButton(
                onPressed: _formChange,
                //  onPressed: _loginPressed, // TODO CHANGE
                child: Text("Placeholder Switch"),
              ),
            ),
          ),
        ]
        )
    );
  }

  Widget _buildLiveQuiz(){

  }

  Widget _buildJoinByPinButton(){

  }

  Widget _buildQuizList(){
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.0),
      height: 200.0,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          Container(
            width: 160.0,
            color: Colors.red,
          ),
          Container(
            width: 160.0,
            color: Colors.blue,
          ),
          Container(
            width: 160.0,
            color: Colors.green,
          ),
          Container(
            width: 160.0,
            color: Colors.yellow,
          ),
          Container(
            width: 160.0,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }



  void _quiz(){
    print('hellow');
  }

  void _formChange() {
    print('UWU');
  }



}


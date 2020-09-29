
import 'package:flutter/material.dart';
import 'package:fuzzy_broccoli/src/QuizTaker/quizQuestion.dart';


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
          SizedBox(height: 50),
          _SwitchButton(),
          // _buildTextFields(),
          // Buttons for navigation
          _buildLiveQuiz(),
          _buildJoinByPinButton(),
          _buildQuizList(),
        ],
      ),
    );
  }

  Widget _SwitchButton(){
    return new Container(
        child: new Row(

          children: <Widget>[
          Expanded (
            child: new ButtonTheme(
              buttonColor: Colors.white,
              child: RaisedButton(
                onPressed: _formChange,
                //  onPressed: _loginPressed, // TODO CHANGE
                child: Text("All"),
              ),
            ),
          ),
            Expanded (
            child: new ButtonTheme(
              buttonColor: Colors.white,
              child: RaisedButton(
                onPressed: _formChange,
                //  onPressed: _loginPressed, // TODO CHANGE
                child: Text("Live"),
              ),
            ),
          ),
            Expanded (
            child: new ButtonTheme(
              buttonColor: Colors.white,
              child: RaisedButton(
                onPressed: _formChange,
                //  onPressed: _loginPressed, // TODO CHANGE
                child: Text("Self Paced"),
              ),
            ),
          ),
        ]
        )
    );
  }

  Widget _buildLiveQuiz(){
    return new Container(
      padding: EdgeInsets.all(16.0),
      child: new Column(
        children: <Widget>[
      new Container(
      child: new TextField(
        controller: _pinFilter,
        decoration: new InputDecoration(
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
            labelText: 'Name'
        ),
        obscureText: false,
      ),
    ),
    ]
    )
    );



  }

  Widget _buildJoinByPinButton(){
    return new Container(
    child: new Column(
    children: <Widget>[
    new ButtonTheme(
    minWidth: 200.0,
    height: 50.0,
    buttonColor: Colors.white,
    child: RaisedButton(
    onPressed: _verifyPin, // TODO CHANGE
    child: Text("Create Account"),
    ),
    ),
    ],
    )
    );
  }

  Widget _listTile(){
    return new Container(
        width: 160.0,
      child: new Column(
          children: <Widget>[
            new Container(
              // TODO GET IMAGE
              //  child: Image(image: AssetImage('graphics/background.png'))
            ),
            new Container(
                child: Center(
                  child: Text("UNI QUIZ",style: TextStyle(height: 5, fontSize: 5,color: Colors.black),),
                )
            ),
            Expanded(child: Container()),
            new Container(
                child: Center(
                  child: Text("WORT WORT WORT",style: TextStyle(height: 5, fontSize: 5,color: Colors.black),),
                )
            ),

          ]
      )
    );
  }

  final items = List<String>.generate(10, (i) => "Item $i");

  Widget _buildQuizList(){
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.0),
      height: 200.0,

      child: ListView.builder(

        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          return
            _listTile();
        },
    )


    );
  }



  void _quiz(){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => quizQuestion()),
    );
  }

  void _formChange() {
    print('UWU');
  }

  void _verifyPin() {

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => quizQuestion()),
    );
    print("TOOD");
  }
}


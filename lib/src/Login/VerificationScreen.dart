import 'package:flutter/material.dart';

class VerificationScreen extends StatefulWidget {
  @override
  _verficationScreen createState() => _verficationScreen();
}

enum FormType {
  Email,
  Code,
  Password,
}
final TextEditingController _emailFilter = new TextEditingController();
final TextEditingController _passwordFilter = new TextEditingController();
final TextEditingController _codeFilter = new TextEditingController();

String _email = "";
String _code = "";
String _password = "";

class _verficationScreen extends State<VerificationScreen>{


  FormType _form = FormType.Email;

  _verficationScreen() {
    _emailFilter.addListener(_emailListen);
    _passwordFilter.addListener(_passwordListen);
    _codeFilter.addListener(_codeListen);
  }

  void _codeListen() {
    if (_codeFilter.text.isEmpty) {
      _code = "";
    } else {
      _code = _codeFilter.text;
    }
  }

  void _emailListen() {
    if (_emailFilter.text.isEmpty) {
      _email = "";
    } else {
      _email = _emailFilter.text;
    }
  }

  void _passwordListen() {
    if (_passwordFilter.text.isEmpty) {
      _password = "";
    } else {
      _password = _passwordFilter.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Container(
        // Background colour scheme controls
        // color: Colors.green,
        // padding: EdgeInsets.all(16.0),
        // App body controls
        child: new SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // Title "UNI QUIZ"
              _buildTitle(),
              SizedBox(height: 20),
              _buildTextFields(),
              // Buttons for navigation
              _buildButtons(),
            ],
          ),
        ),
      ),

    );
  }

  Widget _buildTitle(){
    return new Column(
        children: <Widget>[

          new Container(
              // height: 200,
              // color: Colors.white,
              child: Center(

                child: Text("Recovery",style: TextStyle(height: 5, fontSize: 32,color: Colors.black),),

              )
          )
        ]
    );
  }

  Widget _buildTextFields(){
    if(_form == FormType.Email){
      return new Container(
        padding: EdgeInsets.all(16.0),
        child: new Column(
          children: <Widget>[
            new Container(
              child: new TextField(
                controller: _emailFilter,
                decoration: new InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Email'
                ),
              ),
            ),
          ],
        ),
      );
    }
    else if(_form == FormType.Code){
      return new Container(
        padding: EdgeInsets.all(16.0),
        child: new Column(
          children: <Widget>[
            new Container(
              child: new TextField(
                controller: _codeFilter,
                decoration: new InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Code'
                ),
              ),
            ),
          ],
        ),
      );

    }
    else{
      return new Container(
        padding: EdgeInsets.all(16.0),
        child: new Column(
          children: <Widget>[
            new Container(
              child: new TextField(
                controller: _passwordFilter,
                decoration: new InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'New Password'
                ),
              ),
            ),
          ],
        ),
      );
    }
  }


  Widget _buildButtons(){
    if(_form == FormType.Email){
      return Padding(
        padding: const EdgeInsets.fromLTRB(0,50,0,0),
        child: new Container(
          child: new Column(
            children: <Widget>[
              new ButtonTheme(
                minWidth: 200.0,
                height: 50.0,
                buttonColor: Colors.white,
                child: RaisedButton(
                  onPressed: _emailPressed, // TODO CHANGE
                  child: Text("Send"),
                ),
              ),
            ],
          ),
        ),
      );
    }
    else if(_form == FormType.Code){
      return Padding(
        padding: const EdgeInsets.fromLTRB(0,50,0,0),
        child: new Container(
          child: new Column(
            children: <Widget>[
              new ButtonTheme(
                minWidth: 200.0,
                height: 50.0,
                buttonColor: Colors.white,
                child: RaisedButton(
                  onPressed: _codePressed, // TODO CHANGE
                  child: Text("Send Code"),
                ),
              ),
            ],
          ),
        ),
      );
    }
    else{
      return Padding(
        padding: const EdgeInsets.fromLTRB(0,50,0,0),
        child: new Container(
          child: new Column(
            children: <Widget>[
              new ButtonTheme(
                minWidth: 200.0,
                height: 50.0,
                buttonColor: Colors.white,
                child: RaisedButton(
                  onPressed: _passwordPressed, // TODO CHANGE
                  child: Text("Reset Password"),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }


  
  void _createAccountPressed() {
  }

  void _emailPressed() async {

    setState(() {
      _form = FormType.Code;
    });
  }

  void _codePressed() async {

    setState(() {
      _form =_form = FormType.Password;
    });
  }

  void _passwordPressed(){
    print("transition time");
  }
}


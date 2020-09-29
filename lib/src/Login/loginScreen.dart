import 'package:flutter/material.dart';

import 'VerificationScreen.dart';


class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

// Used for controlling whether the user is logging in or creating an account
// Test code TODO move to relevant areas
enum FormType {
  login,
  register
}

// Test code please ignore for now
// Used to read password/email inputs
class _LoginPageState extends State<LoginPage> {

  final TextEditingController _emailFilter = new TextEditingController();
  final TextEditingController _passwordFilter = new TextEditingController();
  final TextEditingController _confirmEmailFilter = new TextEditingController();
  final TextEditingController _confirmPasswordFilter = new TextEditingController();
  final TextEditingController _userNameFilter = new TextEditingController();



  String _email = "";
  String _cfemail = "";
  String _password = "";
  String _cfpassword = "";
  String _usrname = "";
  FormType _form = FormType.login; // our default setting is to login, and we should switch to creating an account when the user chooses to

  _LoginPageState() {
    _emailFilter.addListener(_emailListen);
    _passwordFilter.addListener(_passwordListen);
    _confirmEmailFilter.addListener(_confirmEmailListen);
    _confirmPasswordFilter.addListener(_confirmPasswordListen);
    _userNameFilter.addListener(_userNameListen);
  }

  void _userNameListen() {
    if (_userNameFilter.text.isEmpty) {
      _usrname = "";
    } else {
      _usrname = _userNameFilter.text;
    }
  }

  void _confirmEmailListen() {
    if (_confirmEmailFilter.text.isEmpty) {
      _cfemail = "";
    } else {
      _cfemail = _confirmEmailFilter.text;
    }
  }

  void _confirmPasswordListen() {
    if (_confirmPasswordFilter.text.isEmpty) {
      _cfpassword = "";
    } else {
      _cfpassword = _confirmPasswordFilter.text;
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

  // Swap in between our two forms, registering and logging in
  void _formChange () async {
    setState(() {
      if (_form == FormType.register) {
        _form = FormType.login;
      } else {
        _form = FormType.register;
      }
    });
  }

  // Primary start up function
  @override
  Widget build(BuildContext context) {
    // Create a new Scaffold
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
              _buildSwitch(),
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

  // Creates the LOGO
  Widget _buildTitle(){
    return new Column(
        children: <Widget>[

          new Container(
              height: 200,
              color: Colors.white,
              child: Center(

                child: Text("Fuzzy Broccoli",style: TextStyle(height: 5, fontSize: 32,color: Colors.black),),

              )
          )
        ]
    );

  }

  Widget _buildSwitch(){

    return new Container(
      child: new Column(
        children: <Widget>[
          new Container(
            child: new ButtonTheme(
              minWidth: 200.0,
              height: 50.0,
              buttonColor: Colors.white,
              child: RaisedButton(
                onPressed: _formChange,
              //  onPressed: _loginPressed, // TODO CHANGE
                child: Text("Placeholder Switch"),
              ),
            ),
          ),
        ],
      ),
    );

  }

  // Buttons and their data collection capabilties
  // Test code please ignore
  // TODO move to necessary locations later on
  Widget _buildTextFields() {
    if(_form == FormType.login) {
      return new Container(
        padding: EdgeInsets.all(35.0),
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
            SizedBox(height: 20),
            new Container(
              child: new TextField(
                controller: _passwordFilter,
                decoration: new InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Password'
                ),
                obscureText: true,
              ),
            )
          ],
        ),
      );
    }
    else{
      return new Container(
        padding: EdgeInsets.all(35.0),
        child: new Column(
          children: <Widget>[
            new Container(
              child: new TextField(
                controller: _userNameFilter,
                decoration: new InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Name'
                ),
                obscureText: true,
              ),
            ),
            SizedBox(height: 20),
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
            SizedBox(height: 20),
            new Container(
              child: new TextField(
                controller: _passwordFilter,
                decoration: new InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Password'
                ),
                obscureText: true,
              ),
            ),
            SizedBox(height: 20),
            new Container(
              child: new TextField(
                controller: _confirmPasswordFilter,
                decoration: new InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Confirm Password'
                ),
                obscureText: true,
              ),
            )
          ],
        ),
      );


    }
  }

  // Buttons used to move to login 2 or login 3
  Widget _buildButtons() {
    if (_form == FormType.login) {
      return Padding(
        // Padding to attempt to align with Wireframe
        padding: const EdgeInsets.fromLTRB(0,50,0,0),
        child: new Container(
          // Column means one widget is on top of another
          child: new Column(
            children: <Widget>[
              // Log in Button
              new ButtonTheme(
                minWidth: 200.0,
                height: 50.0,
                buttonColor: Colors.white,
                child: RaisedButton(
                  onPressed: _loginPressed, // TODO CHANGE
                  child: Text("Log In"),
                ),
              ),
              // More padding to prevent two buttons being too close
              // Optional Forgot password button
              new FlatButton(
                child: new Text('Forgot Password?'),
                onPressed: _passwordReset,
              )
            ],
          ),
        ),
      );
    }
    // Test code please ignore for now
    // TODO move to other place
    else {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0,20,0,0),
        child: new Container(
          child: new Column(
            children: <Widget>[
              new ButtonTheme(
                minWidth: 200.0,
                height: 50.0,
                buttonColor: Colors.white,
                child: RaisedButton(
                  onPressed: _createAccountPressed, // TODO CHANGE
                  child: Text("Create Account"),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  // These functions can self contain any user auth logic required, they all have access to _email and _password

  void _loginPressed () {
    print("Sign Up pressed");
   /* Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage2())
    ); */
  }
  void signUpPressed() {
    print("Sign Up pressed");
  /*  Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage3())
    ); */
  }

  void _createAccountPressed () {
    print('The user wants to create an accoutn with $_email and $_password');

  }

  void _passwordReset () {
    print("The user wants a password reset request sent to $_email");
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => VerificationScreen())
    );
  }
}
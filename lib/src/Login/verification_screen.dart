import 'package:flutter/material.dart';

/// Use : The verification screen to reset your passwords
/// into the application.
/// Type : Stateful Widget
/// Transitions: Insert Email -> INsert Verification code -> Reset Password
class VerificationScreen extends StatefulWidget {
  @override
  _VerificationScreen createState() => _VerificationScreen();
}

// Boiler plat for Stateful Widgets
enum FormType {
  Email,
  Code,
  Password,
}

// Listeners
final TextEditingController _emailFilter = new TextEditingController();
final TextEditingController _passwordFilter = new TextEditingController();
final TextEditingController _codeFilter = new TextEditingController();

class _VerificationScreen extends State<VerificationScreen> {
  // ignore: unused_field
  String _email = "";
  // ignore: unused_field
  String _code = "";
  // ignore: unused_field
  String _password = "";

// Starting form
  FormType _form = FormType.Email;

  _VerificationScreen() {
    _emailFilter.addListener(_emailListen);
    _passwordFilter.addListener(_passwordListen);
    _codeFilter.addListener(_codeListen);
  }

  // Text listeners
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

  // Main app body
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

  /// The title widget defines the logo and
  /// The application name
  Widget _buildTitle() {
    return new Column(children: <Widget>[
      new Container(
          height: 200,
          color: Colors.white,
          child: Center(
            child:
                Image(image: AssetImage('assets/images/Logo_Placeholder.png')),
          ))
    ]);
  }

  // Text Fields
  Widget _buildTextFields() {
    // Email text Field
    if (_form == FormType.Email) {
      return new Container(
        padding: EdgeInsets.all(36.0),
        child: new Column(
          children: <Widget>[
            new Container(
              child: new TextField(
                controller: _emailFilter,
                decoration: new InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Email'),
              ),
            ),
          ],
        ),
      );
    }
    // Code Text Field
    else if (_form == FormType.Code) {
      return new Container(
        padding: EdgeInsets.all(36.0),
        child: new Column(
          children: <Widget>[
            new Container(
              child: new TextField(
                controller: _codeFilter,
                decoration: new InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Code'),
              ),
            ),
          ],
        ),
      );
    }
    // New Password TExt Field
    // TODO add confirm password textfield
    else {
      return new Container(
        padding: EdgeInsets.all(36.0),
        child: new Column(
          children: <Widget>[
            new Container(
              child: new TextField(
                controller: _passwordFilter,
                decoration: new InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'New Password'),
              ),
            ),
          ],
        ),
      );
    }
  }

  // TODO add back button below Send button
  Widget _buildButtons() {
    // Send Button
    if (_form == FormType.Email) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: new Container(
          child: new Column(
            children: <Widget>[
              //  buttonColor: Colors.white,
              new RaisedButton(
                onPressed: _emailPressed, // TODO CHANGE
                child: Text("Send"),
              ),
            ],
          ),
        ),
      );
    }

    // Unique Identification Code
    else if (_form == FormType.Code) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: new Container(
          child: new Column(
            children: <Widget>[
              //  minWidth: 200.0,
              //    height: 50.0,
              //   buttonColor: Colors.white,
              new RaisedButton(
                onPressed: _codePressed, // TODO CHANGE
                child: Text("Send Code"),
              ),

              new FlatButton(
                child: new Text('Back'),
                onPressed: _backToEmail,
              )
            ],
          ),
        ),
      );
    }
    // Reset Password
    // TODO add confirm password field
    else {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: new Container(
          child: new Column(
            children: <Widget>[
              //  minWidth: 200.0,
              //   height: 50.0,
              //    buttonColor: Colors.white,
              new RaisedButton(
                onPressed: _passwordPressed, // TODO CHANGE
                child: Text("Reset Password"),
              ),

              new FlatButton(
                child: new Text('Back'),
                onPressed: _emailPressed,
              )
            ],
          ),
        ),
      );
    }
  }

  // // Methods for Logic
  // void _createAccountPressed() {}

  void _backToEmail() async {
    setState(() {
      _form = FormType.Email;
    });
  }

  void _emailPressed() async {
    setState(() {
      _form = FormType.Code;
    });
  }

  void _codePressed() async {
    setState(() {
      _form = _form = FormType.Password;
    });
  }

  void _passwordPressed() {
    print("transition time");
  }
}

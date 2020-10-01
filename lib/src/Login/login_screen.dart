import 'package:flutter/material.dart';
import './login.dart';
import './register.dart';

/// Use : The Login Screen provides an interface to verify the user and log them
/// into the application.
/// Type : Stateful Widget
/// Transitions: A form change from register to login and login to register
class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LoginScreenState();
}

///
enum FormType { login, register }

class _LoginScreenState extends State<LoginScreen> {
  // our default setting is to login, and we should switch to register when needed
  FormType _form = FormType.login;

  void _formChangeToRegister() async {
    setState(() {
      _form = FormType.register;
    });
  }

  void _formChangeToLogin() async {
    setState(() {
      _form = FormType.login;
    });
  }

  // Primary start up function
  @override
  Widget build(BuildContext context) {
    Widget _login = Login();
    Widget _register = Register();

    // Create a new Scaffold
    return new Scaffold(
      body: new Container(
        /// App body controls
        /// Single scroll view to avoid keyboard overflow when typeing input
        child: new SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // Build title (logo/application name)
              Container(
                  height: 200,
                  color: Colors.white,
                  child: Center(
                    child: Image(
                        image:
                            AssetImage('assets/images/Logo_Placeholder.png')),
                  )),
              // Padding
              SizedBox(height: 40),
              // Switch
              // Functionality to switch between login and register
              _buildSwitch(),
              // Padding
              SizedBox(height: 20),
              // Which form to show
              _form == FormType.login ? _login : _register
            ],
          ),
        ),
      ),
    );
  }

  /// The switch button
  Widget _buildSwitch() {
    return new Container(
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,

        /// NOTE: This is a placeholder button as I cannot find standard material
        /// Components for a switch like button
        /// In the future an animated class will be here to make the button look
        /// Better, I'm not going to do it right now since learning animated
        /// methods appears to be quite time consuming
        /// TODO refactor in future iterations
        children: <Widget>[
          new Container(
            width: 150,
            height: 60,
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Text("Login"),
              // color: Colors.lightGreen[300],
              textColor: Colors.white,
              onPressed: _formChangeToLogin,
            ),
          ),
          SizedBox(width: 10),
          new Container(
            width: 150,
            height: 60,
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Text("Sign Up"),
              // color: Colors.lightGreen[300],
              textColor: Colors.white,
              onPressed: _formChangeToRegister,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'verification_screen.dart';

/// Use : The Login Screen provides an interface to verify the user and log them
/// into the application.
/// Type : Stateful Widget
/// Transitions: A form change from register to login and login to register
class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LoginScreenState();
}


///
enum FormType {
  login,
  register
}

class _LoginScreenState extends State<LoginScreen> {

  // These classes are used to listen for input from the respective text boxes
  final TextEditingController _emailFilter = new TextEditingController();
  final TextEditingController _passwordFilter = new TextEditingController();
  final TextEditingController _confirmEmailFilter = new TextEditingController();
  final TextEditingController _confirmPasswordFilter = new TextEditingController();
  final TextEditingController _userNameFilter = new TextEditingController();


  // Starting string for the controllers above
  String _email = "";
  String _cfemail = "";
  String _password = "";
  String _cfpassword = "";
  String _usrname = "";

  // our default setting is to login, and we should switch to register when needed
  FormType _form = FormType.login;


  _LoginPageState() {
    _emailFilter.addListener(_emailListen);
    _passwordFilter.addListener(_passwordListen);
    _confirmEmailFilter.addListener(_confirmEmailListen);
    _confirmPasswordFilter.addListener(_confirmPasswordListen);
    _userNameFilter.addListener(_userNameListen);
  }

  // Functions which listens for input from the text boxes
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

  // Swap in between our two forms, logging in or creating an account
  void _formChange () async {
    setState(() {
      if (_form == FormType.register) {
        _form = FormType.login;
      } else {
        _form = FormType.register;
      }
    });
  }

  void _formChangeToRegister () async {
    setState(() {

      _form = FormType.register;
    });
  }

  void _formChangeToLogin () async {
    setState(() {

        _form = FormType.login;
      });
  }


  // Primary start up function
  @override
  Widget build(BuildContext context) {
    // Create a new Scaffold
    return new Scaffold(

      body: new Container(
        /// App body controls
        /// Single scroll view to avoid keyboard overflow when typeing input
        child: new SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // Build title
              _buildTitle(),
              // Padding
              SizedBox(height: 20),
              // Functionality to switch between login and register
              _buildSwitch(),
              // Padding
              SizedBox(height: 20),
               // Text fields
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
  Widget _buildTitle(){
    return new Column(
        children: <Widget>[
          new Container(
              height: 200,
              color: Colors.white,
              child: Center(
                child:Image(image: AssetImage('assets/images/Logo_Placeholder.png')),
              )
          )
        ]
    );

  }

  /// The switch button
  Widget _buildSwitch(){


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
          new  Container(
            width: 150,
            height: 60,
            child: RaisedButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0),),
              child: Text("Login"),
             // color: Colors.lightGreen[300],
              textColor: Colors.white,
              onPressed: _formChangeToLogin,
            ),
          ),
          SizedBox(width: 10),
          new  Container(
            width: 150,
            height: 60,
            child: RaisedButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0),),
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

  /// Buttons and their data collection capabilties
  Widget _buildTextFields() {

    // If we are in the form login display this
    if(_form == FormType.login) {
      return new Container(
        padding: EdgeInsets.all(35.0),
        child: new Column(
          children: <Widget>[
            // Text field for email
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
            // Padding between the two textboxes
            SizedBox(height: 20),
            // Text field for password
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

    // Otherwise we display this
    else{
      return new Container(
        padding: EdgeInsets.all(35.0),
        child: new Column(
          children: <Widget>[
            // Text field for name
            new Container(
              child: new TextField(
                controller: _userNameFilter,
                decoration: new InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Name'
                ),
                // obscureText: true,
              ),
            ),
            // Padding
            SizedBox(height: 20),
            // Textfield for Email
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
            // Padding
            SizedBox(height: 20),
            // Text field for password
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
            // padding
            SizedBox(height: 20),
            // Textfield for password confirm
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

  /// Buttons used to submit data or move to password reset
  /// See Verification Screen (Placeholder)
  Widget _buildButtons() {
    // Login
    if (_form == FormType.login) {
      return Padding(
        // Padding to attempt to align with Wireframe
        padding: const EdgeInsets.fromLTRB(0,20,0,0),
        child: new Container(
          // Column means one widget is on top of another
          child: new Column(
            children: <Widget>[
              // Log in Button
              new ButtonTheme(
                minWidth: 310.0,
                height: 50.0,
                buttonColor: Colors.orangeAccent,
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
    // Form change
    else {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0,20,0,0),
        child: new Container(
          child: new Column(
            children: <Widget>[
              new ButtonTheme(
                minWidth: 310.0,
                height: 50.0,
                buttonColor: Colors.orangeAccent,
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
  // logic to be below

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
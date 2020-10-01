import 'package:flutter/material.dart';
import 'verification_screen.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LoginState();
}

class _LoginState extends State<Login> {
  // These classes are used to listen for input from the respective text boxes
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();

  Widget _textFields() {
    return new Column(
      children: <Widget>[
        // Text field for email
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
        ),
        // Text field for password
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmission() {
    return new Container(
      // Column means one widget is on top of another
      child: Column(
        children: <Widget>[
          // Log in Button
          RaisedButton(
            onPressed: _loginPressed, // TODO CHANGE
            child: const Text("Login"),
          ),

          // More padding to prevent two buttons being too close
          // Optional Forgot password button
          FlatButton(
            child: const Text('Forgot Password?'),
            onPressed: _passwordReset,
          )
        ],
      ),
    );
  }

  void _loginPressed() {
    print("Login pressed");
    /* Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage2())
    ); */
  }

  void _passwordReset() {
    print(
        "The user wants a password reset request sent to $_emailController.text");
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => VerificationScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: .75,
      child: Column(
        children: [
          Form(
            child: Column(
              children: [_textFields(), _buildSubmission()],
            ),
          )
        ],
      ),
    );
  }
}

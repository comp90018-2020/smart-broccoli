import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  final TextEditingController _userNameController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: EdgeInsets.all(36.0),
      child: new Column(
        children: <Widget>[
          // Text field for name
          new Container(
            child: new TextField(
              controller: _userNameController,
              decoration: new InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Name'),
              // obscureText: true,
            ),
          ),
          // Padding
          SizedBox(height: 20),
          // Textfield for Email
          new Container(
            child: new TextField(
              controller: _emailController,
              decoration: new InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Email'),
            ),
          ),
          // Padding
          SizedBox(height: 20),
          // Text field for password
          new Container(
            child: new TextField(
              controller: _passwordController,
              decoration: new InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Password'),
              obscureText: true,
            ),
          ),
          // padding
          SizedBox(height: 20),
          RaisedButton(
            onPressed: _createAccountPressed, // TODO CHANGE
            child: Text("Create Account"),
          )
        ],
      ),
    );
  }

  void signUpPressed() {
    print("Sign Up pressed");
    /*  Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage3())
      ); */
  }

  void _createAccountPressed() {
    print(
        'The user wants to create an accoutn with $_emailController.text and $_passwordController.text');
  }
}

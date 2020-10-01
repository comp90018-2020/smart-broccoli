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
    return FractionallySizedBox(
        widthFactor: .70,
        child: Form(
          child: Column(
            children: <Widget>[
              // Text field for name
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TextFormField(
                  controller: _userNameController,
                  decoration: new InputDecoration(labelText: 'Name'),
                  // obscureText: true,
                ),
              ),
              // Textfield for Email
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TextFormField(
                  controller: _emailController,
                  decoration: new InputDecoration(labelText: 'Email'),
                ),
              ),
              // Text field for password
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TextFormField(
                  controller: _passwordController,
                  decoration: new InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
              ),
              // Create account button
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 10),
                child: SizedBox(
                    width: double.infinity,
                    child: RaisedButton(
                      onPressed: _createAccountPressed,
                      child: Text("CREATE ACCOUNT"),
                    )),
              ),
            ],
          ),
        ));
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

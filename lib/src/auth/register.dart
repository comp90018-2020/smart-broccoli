import 'package:flutter/material.dart';

// Register tab
class Register extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _RegisterState();
}

class _RegisterState extends State<Register> {
  // TextField controllers
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  final TextEditingController _nameController = new TextEditingController();

  // Whether password is visible
  bool _passwordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Form(
        child: Column(
          children: <Widget>[
            // Name
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextFormField(
                  controller: _nameController,
                  decoration: new InputDecoration(
                      labelText: 'Name', prefixIcon: Icon(Icons.people)),
                  textCapitalization: TextCapitalization.words),
            ),
            // Email
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextFormField(
                controller: _emailController,
                decoration: new InputDecoration(
                    labelText: 'Email', prefixIcon: Icon(Icons.email)),
              ),
            ),
            // Password
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextFormField(
                controller: _passwordController,
                decoration: new InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    )),
                obscureText: true,
              ),
            ),

            // Create account button
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                    onPressed: _createAccountPressed,
                    child: const Text("CREATE ACCOUNT"),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  void signUpPressed() {
    print("Sign Up pressed");
  }

  void _createAccountPressed() {
    print(
        'The user wants to create an accoutn with ${_emailController.text} and ${_passwordController.text}');
  }
}

import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  final TextEditingController _userNameController = new TextEditingController();

  // Whether password is visible
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: <Widget>[
          // Text field for name
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TextFormField(
              controller: _userNameController,
              decoration: new InputDecoration(
                  labelText: 'Name', prefixIcon: Icon(Icons.people)),
              // obscureText: true,
            ),
          ),
          // Textfield for Email
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TextFormField(
              controller: _emailController,
              decoration: new InputDecoration(
                  labelText: 'Email', prefixIcon: Icon(Icons.email)),
            ),
          ),
          // Text field for password
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
          // Padding(
          //   padding: const EdgeInsets.symmetric(vertical: 8),
          //   child: TextFormField(
          //     controller: _passwordConfirmController,
          //     decoration: new InputDecoration(
          //         labelText: 'Confirm Password',
          //         prefixIcon: Icon(Icons.lock),
          //         suffixIcon: IconButton(
          //           icon: Icon(_passwordVisible
          //               ? Icons.visibility
          //               : Icons.visibility_off),
          //           onPressed: () {
          //             setState(() {
          //               _passwordVisible = !_passwordVisible;
          //             });
          //           },
          //         )),
          //     obscureText: true,
          //   ),
          // ),
          // Create account button
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 10),
            child: SizedBox(
                width: double.infinity,
                child: RaisedButton(
                  onPressed: _createAccountPressed,
                  child: const Text("CREATE ACCOUNT"),
                )),
          ),
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

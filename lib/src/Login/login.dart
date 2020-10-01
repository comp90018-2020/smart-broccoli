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

  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      // Take up 75% of width
      widthFactor: .70,
      child: Column(
        children: [
          // Form TODO: https://flutter.dev/docs/cookbook/forms/validation
          Form(
            child: Column(
              children: [
                // Text field for email
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                        labelText: 'Email', prefixIcon: Icon(Icons.email)),
                  ),
                ),
                // Text field for password
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          // https://stackoverflow.com/questions/49125064
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
                      obscureText: !_passwordVisible),
                ),

                // Log in Button
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: RaisedButton(
                      onPressed: _loginPressed,
                      child: const Text("LOGIN"),
                    ),
                  ),
                ),

                // More padding to prevent two buttons being too close
                // Optional Forgot password button
                FlatButton(
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.underline,
                        color: Colors.white),
                  ),
                  onPressed: _passwordReset,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void _loginPressed() {
    print("Login pressed");
    print("${_emailController.text} ${_passwordController.text}");
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
}

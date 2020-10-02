import 'package:flutter/material.dart';

// Login tab
class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => new _LoginState();
}

class _LoginState extends State<Login> {
  // These classes are used to listen for input from the respective text boxes
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();

  // Whether password is visible
  bool _passwordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        // Form
        // TODO: https://flutter.dev/docs/cookbook/forms/validation
        Form(
          child: Column(
            children: [
              // Email
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                        labelText: 'Email', prefixIcon: Icon(Icons.email)),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).nextFocus()),
              ),
              // Password
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        // Visibility icon
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

              // Login Button
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

              // Optional: Forgot password button
              // FlatButton(
              //   child: const Text(
              //     'Forgot Password?',
              //     style: TextStyle(
              //         fontWeight: FontWeight.normal,
              //         decoration: TextDecoration.underline,
              //         color: Colors.white),
              //   ),
              //   onPressed: _passwordReset,
              // )
            ],
          ),
        )
      ]),
    );
  }

  void _loginPressed() {
    print("Login pressed");
    print("${_emailController.text} ${_passwordController.text}");
  }
}

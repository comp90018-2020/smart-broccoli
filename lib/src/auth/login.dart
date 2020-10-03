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
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Form(
        child: Wrap(
          runSpacing: 16,
          children: [
            // Email
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
            ),
            // Password
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                // Visibility icon
                // https://stackoverflow.com/questions/49125064
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_passwordVisible,
              onFieldSubmitted: (_) => _loginPressed(),
            ),
            // Spacing
            const SizedBox(height: 12),
            // Login Button
            SizedBox(
              width: double.infinity,
              child: RaisedButton(
                onPressed: _loginPressed,
                child: const Text("LOGIN"),
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

            // Join without registering button
            SizedBox(
              width: double.infinity,
              child: MaterialButton(
                child: const Text('SKIP LOGIN'),
                onPressed: _joinAsParticipant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _loginPressed() {
    print("Login pressed");
    print("${_emailController.text} ${_passwordController.text}");
  }

  void _joinAsParticipant() {
    print("Join as participant");
  }
}

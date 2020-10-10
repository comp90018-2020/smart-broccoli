import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';

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

  // Key for form widget, allows for validation
  final _formKey = GlobalKey<FormState>();

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
        key: _formKey,
        child: Wrap(
          runSpacing: 16,
          children: [
            // Email
            TextFormField(
              controller: _emailController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (!EmailValidator.validate(value)) {
                  return 'Email is invalid';
                }
                return null;
              },
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
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Password is empty';
                }
                if (value.length < 8) {
                  return 'Password must be 8 or more characters';
                }
                return null;
              },
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
            Container(height: 0),
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
                textColor: Theme.of(context).colorScheme.onBackground,
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
    if (_formKey.currentState.validate()) {
      print("Login pressed");
      print("${_emailController.text} ${_passwordController.text}");
    }
  }

  void _joinAsParticipant() {
    print("Join as participant");
  }
}

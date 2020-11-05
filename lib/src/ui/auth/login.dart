import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:provider/provider.dart';

import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui/shared/indicators.dart';
import 'package:smart_broccoli/theme.dart';

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

  // Used to determine Autovalidatemode
  bool _formSubmitted = false;

  // Whether password is visible
  bool _passwordVisible = false;

  // Whether login button is disabled
  bool _isLoginButtonDisabled = false;

  // Prevent setState error resulting from auth -> login transition
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

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
              autovalidateMode: _formSubmitted
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
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
              autovalidateMode: _formSubmitted
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Password is empty';
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
                    setState(() => _passwordVisible = !_passwordVisible);
                  },
                ),
              ),
              keyboardType: TextInputType.visiblePassword,
              obscureText: !_passwordVisible,
              onFieldSubmitted: (_) => _loginPressed(),
            ),
            // Spacing
            Container(height: 0),
            // Login Button
            SizedBox(
              width: double.infinity,
              child: RaisedButton(
                disabledColor:
                    SmartBroccoliColourScheme.disabledButtonTextColor,
                onPressed:
                    _isLoginButtonDisabled ? null : () => _loginPressed(),
                child: const Text("LOGIN"),
              ),
            ),

            // Join without registering button
            SizedBox(
              width: double.infinity,
              child: MaterialButton(
                textColor: Theme.of(context).colorScheme.onBackground,
                child: const Text('SKIP LOGIN'),
                onPressed: () => Navigator.of(context).pushNamed("/join"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _loginPressed() async {
    // Disable button
    setState(() => _isLoginButtonDisabled = true);

    // Request
    if (_formKey.currentState.validate()) {
      // Call
      await Provider.of<AuthStateModel>(context, listen: false)
          .login(_emailController.text, _passwordController.text)
          .catchError((err) => showErrSnackBar(context, err.toString()));
    } else {
      setState(() => _formSubmitted = true);
    }

    // Enable login button
    setState(() => _isLoginButtonDisabled = false);
  }
}

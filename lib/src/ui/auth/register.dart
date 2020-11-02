import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:provider/provider.dart';

import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui/shared/indicators.dart';
import 'package:smart_broccoli/theme.dart';

// Register tab
class Register extends StatefulWidget {
  Register({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _RegisterState();
}

class _RegisterState extends State<Register> {
  // TextField controllers
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  final TextEditingController _nameController = new TextEditingController();

  // Key for form widget, allows for validation
  final _formKey = GlobalKey<FormState>();

  // Whether password is visible
  bool _passwordVisible = false;

  // Used to determine Autovalidatemode
  bool _formSubmitted = false;

  // Whether register button is disabled
  bool _isRegisterButtonDisabled = false;

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
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Form(
        key: _formKey,
        child: Wrap(
          runSpacing: 16,
          children: <Widget>[
            // Name
            TextFormField(
              controller: _nameController,
              autovalidateMode: _formSubmitted
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Name is empty';
                }
                return null;
              },
              decoration: new InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.people),
              ),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
            ),
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
              decoration: new InputDecoration(
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
                if (value.length < 8) {
                  return 'Password must be 8 or more characters';
                }
                return null;
              },
              decoration: new InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () =>
                      setState(() => _passwordVisible = !_passwordVisible),
                ),
              ),
              keyboardType: TextInputType.visiblePassword,
              obscureText: !_passwordVisible,
              onFieldSubmitted: (_) => _createAccountPressed,
            ),
            // Spacing
            Container(height: 0),
            // Create account button
            SizedBox(
              width: double.infinity,
              child: RaisedButton(
                disabledColor:
                    SmartBroccoliColourScheme.disabledButtonTextColor,
                onPressed:
                    _isRegisterButtonDisabled ? null : _createAccountPressed,
                child: const Text("CREATE ACCOUNT"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createAccountPressed() async {
    if (_formKey.currentState.validate()) {
      // Disable button
      setState(() => _isRegisterButtonDisabled = true);

      Future<void> register() =>
          Provider.of<AuthStateModel>(context, listen: false).register(
              _emailController.text,
              _passwordController.text,
              _nameController.text);
      Future<void> login() =>
          Provider.of<AuthStateModel>(context, listen: false)
              .login(_emailController.text, _passwordController.text);

      try {
        await register();
        await login();
      } catch (err) {
        showErrSnackBar(context, err.toString());
      }

      // Enable button
      setState(() => _isRegisterButtonDisabled = false);
    } else {
      setState(() => _formSubmitted = true);
    }

    setState(() => _isRegisterButtonDisabled = false);
  }
}

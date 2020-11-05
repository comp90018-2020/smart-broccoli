import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';

/// Name row
class NameField extends TextFormField {
  NameField(
      bool isEdit, TextEditingController _nameController, bool alwaysValidate,
      {String hintText = '',
      TextInputAction textInputAction,
      void Function(String) onFieldSubmitted})
      : super(
          autovalidateMode: alwaysValidate
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          validator: (value) => value.isEmpty ? "Name cannot be empty" : null,
          readOnly: !isEdit,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            labelText: "Name",
            prefixIcon: Icon(Icons.person),
            hintStyle: const TextStyle(color: Colors.black38),
            suffixIcon: IconButton(
              icon: isEdit ? const Icon(Icons.clear) : const Icon(null),
              onPressed: _nameController.clear,
            ),
            hintText: hintText,
          ),
          controller: _nameController,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
        );
}

/// Email row
class EmailField extends TextFormField {
  EmailField(
      bool isEdit, TextEditingController _emailController, bool alwaysValidate,
      {TextInputAction textInputAction, void Function(String) onFieldSubmitted})
      : super(
          autovalidateMode: alwaysValidate
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          validator: (value) =>
              !EmailValidator.validate(value) ? "Email is invalid" : null,
          textAlignVertical: TextAlignVertical.center,
          readOnly: !isEdit,
          decoration: InputDecoration(
            labelText: "Email",
            prefixIcon: Icon(Icons.email),
            hintStyle: const TextStyle(color: Colors.black38),
            suffixIcon: IconButton(
              icon: isEdit ? const Icon(Icons.clear) : const Icon(null),
              onPressed: _emailController.clear,
            ),
          ),
          controller: _emailController,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
        );
}

/// Password row
class PasswordField extends StatefulWidget {
  final bool isEdit;
  final TextEditingController textEditingController;
  final TextInputAction textInputAction;
  final bool alwaysValidate;
  final void Function(String) onFieldSubmitted;

  PasswordField(this.isEdit, this.textEditingController, this.alwaysValidate,
      {this.textInputAction, this.onFieldSubmitted});

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  // Whether password is visible
  bool _passwordVisible = false;

  Widget build(BuildContext context) {
    return TextFormField(
      autovalidateMode: widget.alwaysValidate
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      validator: (value) =>
          value.length < 8 ? "Passwords must be at least 8 characters" : null,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        labelText: "Password",
        prefixIcon: Icon(Icons.lock),
        hintStyle: const TextStyle(color: Colors.black38),
        suffixIcon: IconButton(
          icon: Icon(
            _passwordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() => _passwordVisible = !_passwordVisible);
          },
        ),
      ),
      obscureText: !_passwordVisible,
      controller: widget.textEditingController,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
    );
  }
}

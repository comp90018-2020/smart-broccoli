import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Name row
class NameTableRow extends TableRow {
  NameTableRow(bool isEdit, TextEditingController _nameController)
      : super(
          children: [
            _paddedCell(Text('NAME', style: TextStyle(color: Colors.black38)),
                padding: EdgeInsets.only(left: 16)),
            _paddedCell(
              TextFormField(
                readOnly: !isEdit,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    hintStyle: TextStyle(color: Colors.black38),
                    suffixIcon: IconButton(
                      icon: isEdit ? Icon(Icons.clear) : Icon(null),
                      onPressed: () {},
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: 'John Smith'),
                controller: _nameController,
              ),
              padding: EdgeInsets.only(left: 16),
            ),
          ],
        );
}

/// Email row
class EmailTableRow extends TableRow {
  EmailTableRow(bool isEdit, TextEditingController _nameController)
      : super(
          children: [
            _paddedCell(Text('EMAIL', style: TextStyle(color: Colors.black38)),
                padding: EdgeInsets.only(left: 16)),
            _paddedCell(
              TextFormField(
                textAlignVertical: TextAlignVertical.center,
                readOnly: !isEdit,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    hintStyle: TextStyle(color: Colors.black38),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: isEdit ? Icon(Icons.clear) : Icon(null),
                      onPressed: () {},
                    ),
                    // A space
                    focusedBorder: InputBorder.none,
                    hintText: 'name@example.com'),
                controller: _nameController,
              ),
              padding: EdgeInsets.only(left: 16),
            ),
          ],
        );
}

/// Password row
class PasswordTableRow extends TableRow {
  PasswordTableRow(bool isEdit, TextEditingController _passwordController)
      : super(
          children: [
            _paddedCell(
                Text('Password', style: TextStyle(color: Colors.black38)),
                padding: const EdgeInsets.only(left: 16)),
            _paddedCell(
              TextFormField(
                obscureText: true,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    hintStyle: TextStyle(color: Colors.black38),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {},
                    ),
                    focusedBorder: InputBorder.none,
                    hintText: 'Password'),
                controller: _passwordController,
              ),
              padding: EdgeInsets.only(left: 16),
            ),
          ],
        );
}

/// Confirm password row
class PasswordConfirmTableRow extends TableRow {
  PasswordConfirmTableRow(
      bool isEdit, TextEditingController _passwordController)
      : super(
          children: [
            _paddedCell(
                Text('Confirm Password',
                    style: TextStyle(color: Colors.black38)),
                padding: EdgeInsets.only(left: 16)),
            _paddedCell(
              TextFormField(
                obscureText: true,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    hintStyle: TextStyle(color: Colors.black38),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {},
                    ),
                    // A space
                    focusedBorder: InputBorder.none,
                    hintText: 'Confirm password'),
                controller: _passwordController,
              ),
              padding: EdgeInsets.only(left: 16),
            ),
          ],
        );
}

Widget _paddedCell(Widget child,
        {EdgeInsetsGeometry padding = EdgeInsets.zero}) =>
    TableCell(
      child: Padding(padding: padding, child: child),
    );

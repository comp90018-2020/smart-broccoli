import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  static Widget _paddedCell(Widget child,
          {EdgeInsetsGeometry padding = EdgeInsets.zero}) =>
      TableCell(
        child: Padding(padding: padding, child: child),
      );
}

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

  static Widget _paddedCell(Widget child,
          {EdgeInsetsGeometry padding = EdgeInsets.zero}) =>
      TableCell(
        child: Padding(padding: padding, child: child),
      );
}

class PasswordTable extends TableRow {
  PasswordTable(bool isEdit, TextEditingController _passwordController)
      : super(
          children: isEdit
              ? [
                  _paddedCell(
                      Text('Password', style: TextStyle(color: Colors.black38)),
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
                          focusedBorder: InputBorder.none,
                          hintText: 'password'),
                      controller: _passwordController,
                    ),
                    padding: EdgeInsets.only(left: 16),
                  ),
                ]
              : [Container(), Container()],
        );

  static Widget _paddedCell(Widget child,
          {EdgeInsetsGeometry padding = EdgeInsets.zero}) =>
      TableCell(
        child: Padding(padding: padding, child: child),
      );
}

class PasswordConfirmTable extends TableRow {
  PasswordConfirmTable(bool isEdit, TextEditingController _passwordController)
      : super(
          children: isEdit
              ? [
                  _paddedCell(
                      Text('Confirm Password',
                          style: TextStyle(color: Colors.black38)),
                      padding: EdgeInsets.only(left: 16)),
                  _paddedCell(
                    TextFormField(
                      obscureText: true,
                      textAlignVertical: TextAlignVertical.center,
                      //readOnly: true,

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
                ]
              : [Container(), Container()],
        );

  static Widget _paddedCell(Widget child,
          {EdgeInsetsGeometry padding = EdgeInsets.zero}) =>
      TableCell(
        child: Padding(padding: padding, child: child),
      );
}

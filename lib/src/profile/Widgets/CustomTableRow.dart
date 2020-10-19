import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserNameTableRow extends TableRow {
  /// Creates a padded table cell
  /// I can't figure out a way to abstract this out of the common classes
  /// So I guess it stays here for now
  static Widget _paddedCell(Widget child,
          {EdgeInsetsGeometry padding = EdgeInsets.zero}) =>
      TableCell(
        child: Padding(padding: padding, child: Expanded(child: child)),
      );

  UserNameTableRow(TextEditingController ctrl)
      : super(children: [
          _paddedCell(Text('NAME', style: TextStyle(color: Colors.black38)),
              padding: EdgeInsets.only(left: 16)),
          _paddedCell(
            TextFormField(
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  hintStyle: TextStyle(color: Colors.black38),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {},
                  ),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: 'John Smith'),
              controller: ctrl,
            ),
            padding: EdgeInsets.only(left: 16),
          ),
        ]);
}

class EmailTableRow extends TableRow {
  /// Creates a padded table cell
  /// I can't figure out a way to abstract this out of the common classes
  /// So I guess it stays here for now
  static Widget _paddedCell(Widget child,
          {EdgeInsetsGeometry padding = EdgeInsets.zero}) =>
      TableCell(
        child: Padding(padding: padding, child: Expanded(child: child)),
      );

  EmailTableRow(TextEditingController ctrl)
      : super(
          children: [
            _paddedCell(Text('EMAIL', style: TextStyle(color: Colors.black38)),
                padding: EdgeInsets.only(left: 16)),
            _paddedCell(
              TextFormField(
                textAlignVertical: TextAlignVertical.center,
                readOnly: true,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    hintStyle: TextStyle(color: Colors.black38),
                    border: InputBorder.none,
                    suffixIcon: Icon(IconData(0x20)),
                    // A space
                    focusedBorder: InputBorder.none,
                    hintText: 'name@example.com'),
                controller: ctrl,
              ),
              padding: EdgeInsets.only(left: 16),
            ),
          ],
        );
}

class PassWordTableRow extends TableRow {
  /// Creates a padded table cell
  /// I can't figure out a way to abstract this out of the common classes
  /// So I guess it stays here for now
  static Widget _paddedCell(Widget child,
          {EdgeInsetsGeometry padding = EdgeInsets.zero}) =>
      TableCell(
        child: Padding(padding: padding, child: Expanded(child: child)),
      );

  PassWordTableRow(TextEditingController ctrl)
      : super(
          children: [
            _paddedCell(Text('EMAIL', style: TextStyle(color: Colors.black38)),
                padding: EdgeInsets.only(left: 16)),
            _paddedCell(
              TextFormField(
                textAlignVertical: TextAlignVertical.center,
                readOnly: true,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    hintStyle: TextStyle(color: Colors.black38),
                    border: InputBorder.none,
                    suffixIcon: Icon(IconData(0x20)),
                    // A space
                    focusedBorder: InputBorder.none,
                    hintText: 'name@example.com'),
                controller: ctrl,
              ),
              padding: EdgeInsets.only(left: 16),
            ),
          ],
        );
}

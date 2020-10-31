import 'package:flutter/material.dart';

/// Table used by profile pages
class TableCard extends Material {
  TableCard(List<TableRow> children)
      : super(
          type: MaterialType.card,
          elevation: 3,
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: const {
              0: FlexColumnWidth(0.3),
              1: FlexColumnWidth(0.7)
            },
            border: TableBorder.all(width: 0.8, color: Colors.black12),
            children: children,
          ),
        );
}

/// Name row
class NameTableRow extends TableRow {
  NameTableRow(bool isEdit, TextEditingController _nameController,
      {String hintText = 'Name',
      TextInputAction textInputAction,
      void Function(String) onFieldSubmitted})
      : super(
          children: [
            _paddedCell(
                const Text('NAME',
                    style: const TextStyle(color: Colors.black38)),
                padding: const EdgeInsets.only(left: 16)),
            _paddedCell(
              TextFormField(
                readOnly: !isEdit,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  hintStyle: const TextStyle(color: Colors.black38),
                  suffixIcon: IconButton(
                    icon: isEdit ? const Icon(Icons.clear) : const Icon(null),
                    onPressed: _nameController.clear,
                  ),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: hintText,
                ),
                controller: _nameController,
                textInputAction: textInputAction,
                onFieldSubmitted: onFieldSubmitted,
              ),
              padding: const EdgeInsets.only(left: 16),
            ),
          ],
        );
}

/// Email row
class EmailTableRow extends TableRow {
  EmailTableRow(bool isEdit, TextEditingController _emailController,
      {String hintText = 'Email',
      TextInputAction textInputAction,
      void Function(String) onFieldSubmitted})
      : super(
          children: [
            _paddedCell(
                const Text('EMAIL',
                    style: const TextStyle(color: Colors.black38)),
                padding: const EdgeInsets.only(left: 16)),
            _paddedCell(
              TextFormField(
                textAlignVertical: TextAlignVertical.center,
                readOnly: !isEdit,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  hintStyle: const TextStyle(color: Colors.black38),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: isEdit ? const Icon(Icons.clear) : const Icon(null),
                    onPressed: _emailController.clear,
                  ),
                  // A space
                  focusedBorder: InputBorder.none,
                  hintText: hintText,
                ),
                controller: _emailController,
                textInputAction: textInputAction,
                onFieldSubmitted: onFieldSubmitted,
              ),
              padding: const EdgeInsets.only(left: 16),
            ),
          ],
        );
}

/// Password row
class PasswordTableRow extends TableRow {
  PasswordTableRow(bool isEdit, TextEditingController _passwordController,
      {String hintText = 'Password',
      TextInputAction textInputAction,
      void Function(String) onFieldSubmitted})
      : super(
          children: [
            _paddedCell(
                Text('Password', style: const TextStyle(color: Colors.black38)),
                padding: const EdgeInsets.only(left: 16)),
            _paddedCell(
              TextFormField(
                obscureText: true,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  hintStyle: const TextStyle(color: Colors.black38),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _passwordController.clear,
                  ),
                  focusedBorder: InputBorder.none,
                  hintText: hintText,
                ),
                controller: _passwordController,
                textInputAction: textInputAction,
                onFieldSubmitted: onFieldSubmitted,
              ),
              padding: const EdgeInsets.only(left: 16),
            ),
          ],
        );
}

/// Confirm password row
class PasswordConfirmTableRow extends TableRow {
  PasswordConfirmTableRow(
      bool isEdit, TextEditingController _passwordController,
      {String hintText = 'Confirm password',
      TextInputAction textInputAction,
      void Function(String) onFieldSubmitted})
      : super(
          children: [
            _paddedCell(
                Text('Confirm Password',
                    style: const TextStyle(color: Colors.black38)),
                padding: const EdgeInsets.only(left: 16)),
            _paddedCell(
              TextFormField(
                obscureText: true,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  hintStyle: const TextStyle(color: Colors.black38),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _passwordController.clear,
                  ),
                  // A space
                  focusedBorder: InputBorder.none,
                  hintText: hintText,
                ),
                controller: _passwordController,
                textInputAction: textInputAction,
                onFieldSubmitted: onFieldSubmitted,
              ),
              padding: const EdgeInsets.only(left: 16),
            ),
          ],
        );
}

Widget _paddedCell(Widget child,
        {EdgeInsetsGeometry padding = EdgeInsets.zero}) =>
    TableCell(
      child: Padding(padding: padding, child: child),
    );

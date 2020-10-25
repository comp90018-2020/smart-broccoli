import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_broccoli/src/models.dart';

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
  NameTableRow(bool isEdit, TextEditingController _nameController)
      : super(
          children: [
            _paddedCell(
                const Text('NAME',
                    style: const TextStyle(color: Colors.black38)),
                padding: const EdgeInsets.only(left: 16)),
            _paddedCell(
              Consumer<UserProfileModel>(
                builder: (context, profile, child) => TextFormField(
                  readOnly: !isEdit,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    hintStyle: const TextStyle(color: Colors.black38),
                    suffixIcon: IconButton(
                      icon: isEdit ? const Icon(Icons.clear) : const Icon(null),
                      onPressed: () {},
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: profile.user != null && profile.user.isAnonymous
                        ? "(anonymous)"
                        : null,
                  ),
                  controller: _nameController,
                ),
              ),
              padding: const EdgeInsets.only(left: 16),
            ),
          ],
        );
}

/// Email row
class EmailTableRow extends TableRow {
  EmailTableRow(bool isEdit, TextEditingController _emailController)
      : super(
          children: [
            _paddedCell(
                const Text('EMAIL', style: TextStyle(color: Colors.black38)),
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
                    onPressed: () {},
                  ),
                  // A space
                  focusedBorder: InputBorder.none,
                ),
                controller: _emailController,
              ),
              padding: const EdgeInsets.only(left: 16),
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
                      onPressed: () {},
                    ),
                    focusedBorder: InputBorder.none,
                    hintText: 'Password'),
                controller: _passwordController,
              ),
              padding: const EdgeInsets.only(left: 16),
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
                      onPressed: () {},
                    ),
                    // A space
                    focusedBorder: InputBorder.none,
                    hintText: 'Confirm password'),
                controller: _passwordController,
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

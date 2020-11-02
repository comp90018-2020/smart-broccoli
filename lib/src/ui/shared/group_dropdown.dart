import 'package:flutter/material.dart';
import 'package:smart_broccoli/src/data.dart';

/// Group dropdown list
class GroupDropdown extends StatelessWidget {
  /// List of groups
  final List<Group> groups;

  /// Current dropdown value
  final int value;

  /// OnChanged function
  final void Function(int value) onChanged;

  /// Items centered?
  final bool centered;

  /// Default text
  final String defaultText;

  GroupDropdown(this.groups, this.value,
      {this.onChanged,
      this.centered = false,
      this.defaultText = "Select a group"});

  /// Abtracts centered text
  Widget _centeredText(String text) => centered
      ? Center(child: Text(text, textAlign: TextAlign.center))
      : Text(text);

  Widget build(BuildContext context) {
    return DropdownButton(
      elevation: 0,
      isExpanded: true,
      value: value,
      items: [
        DropdownMenuItem(child: _centeredText(defaultText), value: null),
        ...groups.map((group) => DropdownMenuItem(
              child: _centeredText(group.nameWithDefaultGroup),
              value: group.id,
            ))
      ],
      onChanged: onChanged,
    );
  }
}

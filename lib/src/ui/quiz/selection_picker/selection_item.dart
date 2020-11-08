import 'package:flutter/material.dart';

class SelectionItem {
  String name;
  bool isSelected;
  dynamic identifier;

  SelectionItem(
      {@required this.name,
      @required this.isSelected,
      @required this.identifier});
}

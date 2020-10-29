import 'package:flutter/material.dart';
import 'page.dart';

/// A centered page
class CenteredPage extends CustomPage {
  /// Constructs a custom page
  CenteredPage(
      {@required String title,
      @required Widget child,
      hasDrawer = false,
      primary = true,
      bool secondaryBackgroundColour = false,
      List<Widget> background,
      Widget floatingActionButton})
      : super(
            title: title,
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  alignment: Alignment.topCenter,
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: LayoutBuilder(
                      builder: (context, constraints) => FractionallySizedBox(
                          widthFactor: constraints.maxWidth < 800 ? 0.7 : 0.5,
                          child: child)),
                ),
              ),
            ),
            hasDrawer: hasDrawer,
            primary: primary,
            floatingActionButton: floatingActionButton,
            background: background,
            secondaryBackgroundColour: secondaryBackgroundColour);
}

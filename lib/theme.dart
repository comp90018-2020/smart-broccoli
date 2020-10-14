import 'package:flutter/material.dart';

class SmartBroccoliColourScheme extends ColorScheme {
  static const Color tabHolderBackground = Color(0xFF82C785);
  static const Color tabHolderPill = Color(0xFFFEC12D);
  static const Color tabHolderPillText = Color(0xFF654C12);
  static const Color logoContainerBackground = Colors.white;
  static const Color inputFieldColor = Colors.white;

  SmartBroccoliColourScheme()
      : super.light(
          background: Color(0xFF4CAF50),
          onBackground: Colors.white,
          primary: Color(0xFFFEC12D),
          secondary: Color(0xFF654C12),
          secondaryVariant: Color(0xFFAEAEAE),
        );
}

/// Singleton class holding the app's `ThemeData` object
class SmartBroccoliTheme {
  static final ThemeData themeData = ThemeData(
    backgroundColor: Color(0xFF4CAF50),
    primaryColor: Color(0xFF4CAF50),
    colorScheme: SmartBroccoliColourScheme(),
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(6)),
      ),
      padding: EdgeInsets.symmetric(vertical: 15),
    ),
    textTheme: TextTheme(
        button: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        subtitle1: TextStyle(
          fontSize: 14,
        ),
        headline6:
            TextStyle(fontWeight: FontWeight.normal, color: Color(0xFF707070))),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      filled: true,
      fillColor: SmartBroccoliColourScheme.inputFieldColor,
      border: UnderlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
    ),
    tabBarTheme: TabBarTheme(
      labelColor: SmartBroccoliColourScheme.tabHolderPillText,
      unselectedLabelColor: Colors.white,
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: SmartBroccoliColourScheme.tabHolderPill,
      ),
    ),
  );

  /// Shape for round RaisedButton
  static final ShapeBorder raisedButtonShape =
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(20));

  /// Padding for round RaisedButton
  static final EdgeInsetsGeometry raisedButtonTextPadding =
      EdgeInsets.symmetric(horizontal: 8);
}

/// Widget to hold the app logo on auth screen
class LogoContainer extends Container {
  LogoContainer({@required Widget child})
      : super(
          height: 200,
          color: SmartBroccoliColourScheme.logoContainerBackground,
          child: child,
        );
}

/// Widget to create sliding-pill-style tabs
class TabHolder extends FractionallySizedBox {
  TabHolder(
      {@required List<Tab> tabs,
      double widthFactor = 0.5,
      EdgeInsetsGeometry margin = EdgeInsets.zero,
      void Function(int) onTap})
      : super(
          widthFactor: widthFactor,
          child: Container(
            margin: margin,
            decoration: const BoxDecoration(
              color: SmartBroccoliColourScheme.tabHolderBackground,
              borderRadius: BorderRadius.all(Radius.circular(25)),
            ),
            child: TabBar(
              tabs: tabs,
              onTap: onTap,
            ),
          ),
        );
}

class AnswerColours {
  /// Correct
  static Color correct = Color(0xFF4CAF50);

  /// Selected
  static Color selected = Color(0xFFFEC12D);

  /// Default
  static Color normal = Colors.white;
}

class LobbyDivider extends Divider {
  LobbyDivider()
      : super(
          thickness: 3,
          height: 50,
          color: Colors.orangeAccent,
        );
}

class BoxDecoration1 extends BoxDecoration {
  BoxDecoration1()
      : super(
          // You need this line or the box will be transparent
          color: Colors.lightGreen,
          shape: BoxShape.circle,
        );
}

class LobbyTimerBoxDecoration extends BoxDecoration {
  LobbyTimerBoxDecoration()
      : super(
          border: new Border.all(
              color: Colors.orangeAccent, width: 3, style: BorderStyle.solid),
          // You need this line or the box will be transparent
          color: Colors.white,
          shape: BoxShape.circle,
        );
}

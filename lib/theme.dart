
import 'package:flutter/material.dart';

class FuzzyBroccoliColourScheme extends ColorScheme {
  static const Color tabHolderBackground = Color(0xFF82C785);
  static const Color tabHolderPill = Color(0xFFFEC12D);
  static const Color tabHolderPillText = Color(0xFF654C12);
  static const Color logoContainerBackground = Colors.white;
  static const Color inputFieldColor = Colors.white;

  FuzzyBroccoliColourScheme()
      : super.light(
    background: Color(0xFF4CAF50),
    onBackground: Colors.white,
    primary: Color(0xFFFEC12D),
    secondary: Color(0xFF654C12),
    secondaryVariant: Color(0xFFAEAEAE),
  );
}

/// Singleton class holding the app's `ThemeData` object
class FuzzyBroccoliTheme {
  static final _instance = FuzzyBroccoliTheme._internal();
  final ThemeData _themeData = ThemeData(
    colorScheme: FuzzyBroccoliColourScheme(),
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
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      filled: true,
      fillColor: FuzzyBroccoliColourScheme.inputFieldColor,
      border: UnderlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
    ),
    tabBarTheme: TabBarTheme(
      labelColor: FuzzyBroccoliColourScheme.tabHolderPillText,
      unselectedLabelColor: Colors.white,
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: FuzzyBroccoliColourScheme.tabHolderPill,
      ),
    ),
  );
  ThemeData get themeData => _themeData;

  FuzzyBroccoliTheme._internal();
  factory FuzzyBroccoliTheme() {
    return _instance;
  }
}

/// Widget to hold the app logo on auth screen
class LogoContainer extends Container {
  LogoContainer({@required Widget child})
      : super(
    height: 200,
    color: FuzzyBroccoliColourScheme.logoContainerBackground,
    child: child,
  );
}

/// Widget to create sliding-pill-style tabs
class TabHolder extends FractionallySizedBox {
  TabHolder(
      {@required List<Tab> tabs,
        double widthFactor = 0.5,
        margin: EdgeInsetsGeometry})
      : super(
    widthFactor: widthFactor,
    child: Container(
      margin: margin,
      decoration: const BoxDecoration(
        color: FuzzyBroccoliColourScheme.tabHolderBackground,
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
      child: TabBar(tabs: tabs),
    ),
  );
}
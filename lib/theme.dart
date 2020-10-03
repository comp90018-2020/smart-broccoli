import 'package:flutter/material.dart';

/// Singleton class holding the app's `ThemeData` object
class FuzzyBroccoliTheme {
  static final _instance = FuzzyBroccoliTheme._internal();
  final ThemeData _themeData = ThemeData(
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(6)),
      ),
      padding: EdgeInsets.symmetric(vertical: 15),
      buttonColor: Color(0xFFFEC12D),
      textTheme: ButtonTextTheme.primary,
    ),
    textTheme: TextTheme(
      button: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      subtitle1: TextStyle(
        fontSize: 14,
        // color: Color(0xFFAEAEAE)
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      filled: true,
      fillColor: Colors.white,
      border: UnderlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
    ),
    tabBarTheme: TabBarTheme(
      labelColor: Color(0xFF654C12),
      unselectedLabelColor: Colors.white,
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Color(0xFFFEC12D),
      ),
    ),
    scaffoldBackgroundColor: Color(0xFF4CAF50),
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
          color: Colors.white,
          child: child,
        );
}

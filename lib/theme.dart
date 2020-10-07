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
  static final ThemeData _themeData = ThemeData(
    primaryColor: Color(0xFF4CAF50),
    scaffoldBackgroundColor: Color(0xFF4CAF50),
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
    ),
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

  ThemeData get themeData => _themeData;
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
      EdgeInsetsGeometry margin = EdgeInsets.zero})
      : super(
          widthFactor: widthFactor,
          child: Container(
            margin: margin,
            decoration: const BoxDecoration(
              color: SmartBroccoliColourScheme.tabHolderBackground,
              borderRadius: BorderRadius.all(Radius.circular(25)),
            ),
            child: TabBar(tabs: tabs),
          ),
        );
}

class AnswerColours {
  static Color correct() {
    return Colors.greenAccent;
  }

  static Color selected() {
    return Colors.orangeAccent;
  }

  static Color def() {
    return Colors.white;
  }
}

class Divider1 extends Divider {
  Divider1()
      : super(
          thickness: 5,
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

class BoxDecoration2 extends BoxDecoration {
  BoxDecoration2()
      : super(
          border: new Border.all(
              color: Colors.orangeAccent,
              width: 5.0,
              style: BorderStyle.solid),
          // You need this line or the box will be transparent
          color: Colors.white,
          shape: BoxShape.circle,
        );
}

class playerStatsCard extends Card{
  playerStatsCard(name) : super(
      color: Colors.yellow,
      elevation: 10,
      child:  Align(
        alignment: Alignment.bottomCenter,
        child: Text(name),
      )
  );
}

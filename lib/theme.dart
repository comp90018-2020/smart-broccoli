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
    accentColor: Colors.green,
    colorScheme: SmartBroccoliColourScheme(),
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(6)),
      ),
      padding: EdgeInsets.symmetric(vertical: 15),
    ),
    floatingActionButtonTheme:
        FloatingActionButtonThemeData(backgroundColor: Color(0xFFFEC12D)),
    textTheme: TextTheme(
        button: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        subtitle1: TextStyle(
          fontSize: 14,
        ),
        headline6: TextStyle(fontWeight: FontWeight.normal)),
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
    textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.green))),
  );

  /// Shape for round RaisedButton
  static final ShapeBorder raisedButtonShape =
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(20));

  /// Padding for round RaisedButton
  static final EdgeInsetsGeometry raisedButtonTextPadding =
      EdgeInsets.symmetric(horizontal: 20);

  /// Winner text style (1, 2, 3)
  static final TextStyle leaderboardRankStyle = TextStyle(
      fontSize: 16, color: Color(0xFF696E69), fontWeight: FontWeight.bold);

  /// List item text style
  static final TextStyle listItemTextStyle =
      TextStyle(color: Color(0xFF656565), fontWeight: FontWeight.bold);
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
          height: 20,
          color: Colors.orangeAccent,
        );
}

class WinnerBubble extends BoxDecoration {
  WinnerBubble()
      : super(
          // You need this line or the box will be transparent
          color: Color(0xFF8DCC8F),
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

class ProfileTheme {
  static Widget profileBackground(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Column(
      children: <Widget>[
        Container(
          height: height / 8,
          color: Colors.green,
        ),
        Expanded(
          child: Container(
            color: Colors.white,
          ),
        )
      ],
    );
  }

  static BoxDecoration bd1() {
    return BoxDecoration(
      border: Border(
        top: BorderSide(
            color: Colors.black12, width: 2, style: BorderStyle.solid),
        bottom: BorderSide(
          color: Colors.black12,
          width: 2,
          style: BorderStyle.solid,
        ),
        right: BorderSide(
          color: Colors.black12,
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
    );
  }

  static BoxDecoration bd2() {
    return BoxDecoration(
      border: Border(
        right: BorderSide(
          color: Colors.black12,
          width: 2,
          style: BorderStyle.solid,
        ),
        bottom: BorderSide(
          color: Colors.black12,
          width: 2,
          style: BorderStyle.solid,
        ),
        left: BorderSide(
          color: Colors.black12,
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
    );
  }

  static BoxDecoration bd3() {
    return BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: Colors.black12,
          width: 2,
          style: BorderStyle.solid,
        ),
        right: BorderSide(
          color: Colors.black12,
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
    );
  }
}

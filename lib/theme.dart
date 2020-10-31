import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SmartBroccoliColourScheme extends ColorScheme {
  static const Color tabHolderBackground = Color(0xFF82C785);
  static const Color tabHolderPill = Color(0xFFFEC12D);
  static const Color tabHolderPillText = Color(0xFF654C12);
  static const Color logoContainerBackground = Colors.white;
  static const Color inputFieldColor = Colors.white;
  static const Color membersTabBackground = Colors.white;
  static const Color disabledButtonTextColor = Color(0xFFC8E6C9);

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
    primaryColorDark: Color(0xFF419644),
    accentColor: Colors.green,
    disabledColor: Colors.green[900],
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

  /// Round raised button
  static final ShapeBorder raisedButtonShapeRound =
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(100));

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
  LogoContainer()
      : super(
          height: 250,
          color: SmartBroccoliColourScheme.logoContainerBackground,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    width: 125,
                    height: 125,
                    image: AssetImage('assets/icon.png'),
                  ),
                  Text(
                    'Smart Broccoli',
                    style: TextStyle(
                      fontSize: 36,
                      color: Color(0xFF125E12),
                      fontFamily: 'PatrickHandSC',
                    ),
                  )
                ],
              ),
            ),
          ),
        );
}

/// Widget to create sliding-pill-style tabs
class TabHolder extends StatelessWidget {
  /// List of tabs
  final List<Tab> tabs;

  /// Horizontal width factor (relative to parent)
  final double widthFactor;

  /// Margin
  final EdgeInsetsGeometry margin;

  /// Horizontal width constraint
  final BoxConstraints constraints;

  /// Tab tap
  final void Function(int) onTap;

  TabHolder(
      {@required this.tabs,
      this.widthFactor = 0.5,
      this.margin = EdgeInsets.zero,
      this.constraints,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    Widget inner = Container(
      margin: margin,
      decoration: const BoxDecoration(
        color: SmartBroccoliColourScheme.tabHolderBackground,
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
      child: TabBar(
        tabs: tabs,
        onTap: onTap,
      ),
    );

    return FractionallySizedBox(
      // Width factor of parent
      widthFactor: widthFactor,
      child: constraints != null
          // Apply horizontal width constraint
          ? Center(
              child: Container(constraints: constraints, child: inner),
            )
          : inner,
    );
  }
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

class UserAvatar extends ClipOval {
  UserAvatar(String filePath, {double maxRadius: 20})
      : super(
          child: filePath == null
              ? SvgPicture.asset("assets/account_circle-black-24dp.svg",
                  width: maxRadius * 2,
                  height: maxRadius * 2,
                  color: Color(0xFF4CAF50))
              : Container(
                  child: CircleAvatar(
                      backgroundImage: Image.file(File(filePath)).image),
                ),
        );
}

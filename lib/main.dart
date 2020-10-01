import 'src/Login/login_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

/// Main entrance class
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Test Flutter',

      /// A issue I've encountered is that not everything can be put into
      /// Theme Data, since out buttons are not all the same
      /// Also for some weird reason, padding also needs to be added
      /// Manually, hopefully a solution can be found soon.
      theme: ThemeData(
        buttonTheme: ButtonThemeData(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(6))),
            padding: EdgeInsets.symmetric(vertical: 15),
            buttonColor: Color(0xFFFEC12D),
            textTheme: ButtonTextTheme.accent,
            // https://stackoverflow.com/questions/56194168
            colorScheme: Theme.of(context)
                .colorScheme
                .copyWith(secondary: Color(0xFF755915))),
        textTheme: TextTheme(
            button: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            subtitle1: TextStyle(
              fontSize: 14,
              // color: Color(0xFFAEAEAE)
            )),
        inputDecorationTheme: InputDecorationTheme(
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            filled: true,
            fillColor: Colors.white,
            border: UnderlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)))),
        tabBarTheme: TabBarTheme(
            labelColor: Color(0xFF654C12),
            unselectedLabelColor: Colors.white,
            // unselectedLabelColor: Color(),
            indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Color(0xFFFEC12D))),
        scaffoldBackgroundColor: Color(0xFF4CAF50),
      ),
      // Initialise the log in page
      home: LoginScreen(),
    );
  }
}

import 'src/Login/login_screen.dart';
import 'src/theme/theme.dart';
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
          buttonColor: Colors.orangeAccent,
          minWidth: 300.0,
          height: 50.0,
        ),
        inputDecorationTheme:
            InputDecorationTheme(contentPadding: EdgeInsets.all(5.0)),
        scaffoldBackgroundColor: Color(0xFF00C853),
      ),
      // Initialise the log in page
      home: LoginScreen(),
    );
  }
}

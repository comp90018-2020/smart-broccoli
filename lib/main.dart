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

      theme: ThemeData(
        buttonTheme: ButtonThemeData(
        buttonColor: Colors.orangeAccent,
          minWidth: 200.0,
          height: 50.0,
      ),

        scaffoldBackgroundColor: Color(0xFF00C853),
      ),
      // Initialise the log in page
      home: LoginScreen(),
    );
  }
}
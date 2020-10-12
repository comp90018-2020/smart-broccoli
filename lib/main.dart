import 'package:flutter/material.dart';
import 'src/quiz/quiz.dart';
import 'package:smart_broccoli/theme.dart';
// import 'src/auth/auth_screen.dart';

void main() => runApp(MyApp());

/// Main entrance class
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Broccoli',
      theme: SmartBroccoliTheme().themeData,
      //routes: {'/auth': (context) => AuthScreen()},
      //initialRoute: '/auth',
      // Debug purposes only, replace with above later on
      //routes: {'/auth': (context) => AuthScreen()},
      routes: {'/take_quiz': (context) => Quiz()},
      initialRoute: '/take_quiz',
    );
  }
}

import 'src/Login/loginScreen.dart';
import 'src/theme/theme.dart';
import 'package:flutter/material.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Test Flutter',
      theme: theme.getThemeData(),
      home: LoginPage(),
    );
  }
}
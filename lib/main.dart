import 'package:flutter/material.dart';
import 'src/QuizTaker/quizMaker.dart';
import 'src/Theme/theme.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme.getThemeData(),
      debugShowCheckedModeBanner: false,
      title: 'Test Flutter',
      home: quizMaker(),
    );
  }
}
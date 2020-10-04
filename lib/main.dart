import 'package:flutter/material.dart';
import 'package:fuzzy_broccoli/theme.dart';
import 'src/QuizTaker/quizMaker.dart';



void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: FuzzyBroccoliTheme().themeData,
      debugShowCheckedModeBanner: false,
      title: 'Test Flutter',
      home: quizMaker(),
    );
  }
}
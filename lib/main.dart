import 'package:flutter/material.dart';
import 'package:fuzzy_broccoli/theme.dart';
import 'src/QuizTaker/quizTaker.dart';



void main() => runApp(MyApp());

/// Main entrance class
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      // Warning, this code needs to be changed if ported into main
      theme: FuzzyBroccoliTheme().themeData,
      debugShowCheckedModeBanner: false,
      title: 'Test Flutter',
      home: quizTaker(),

    );
  }
}
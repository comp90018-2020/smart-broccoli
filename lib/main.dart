import 'package:flutter/material.dart';
import 'package:fuzzy_broccoli/theme.dart';

import 'src/auth/auth_screen.dart';

void main() => runApp(MyApp());

/// Main entrance class
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fuzzy Broccoli',
      theme: FuzzyBroccoliTheme().themeData,
      routes: {'/auth': (context) => AuthScreen()},
      initialRoute: '/auth',
    );
  }
}

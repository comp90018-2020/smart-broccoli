import 'package:flutter/material.dart';
import 'package:smart_broccoli/src/auth/auth_screen.dart';
import 'package:smart_broccoli/theme.dart';

void main() => runApp(MyApp());

/// Main entrance class
class MyApp extends StatelessWidget {
  final items = List<String>.generate(10000, (i) => "Item $i");

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Broccoli',
      theme: SmartBroccoliTheme().themeData,
      routes: {
        '/auth': (context) => AuthScreen(),
      },
      initialRoute: '/auth',
    );
  }
}

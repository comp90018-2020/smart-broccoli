import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_broccoli/cache.dart';
import 'package:smart_broccoli/models.dart';
import 'package:smart_broccoli/theme.dart';

import 'src/auth/auth_screen.dart';

void main() async {
  final KeyValueStore _keyValueStore = MainMemKeyValueStore();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthStateModel(_keyValueStore))
      ],
      child: MyApp(),
    ),
  );
}

/// Main entrance class
class MyApp extends StatelessWidget {
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

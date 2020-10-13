import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_broccoli/cache.dart';
import 'package:smart_broccoli/models.dart';
import 'package:smart_broccoli/src/auth/auth_screen.dart';
import 'package:smart_broccoli/src/auth/init_page.dart';
import 'package:smart_broccoli/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final KeyValueStore _keyValueStore = await SharedPrefsKeyValueStore.create();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthStateModel(_keyValueStore))
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  State createState() => _MyAppState();
}

/// Main entrance class
class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> mainNavigator = GlobalKey<NavigatorState>();
  bool started = false;

  @override
  Widget build(BuildContext context) {
    AuthStateModel state = Provider.of<AuthStateModel>(context, listen: true);
    if (started)
      mainNavigator.currentState
          .pushReplacementNamed(state.inSession ? '/home' : '/auth');
    started = true;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Broccoli',
      theme: SmartBroccoliTheme().themeData,
      routes: {
        '/auth': (context) => AuthScreen(),
        '/home': (context) => InitialRouter(),
      },
      navigatorKey: mainNavigator,
      onGenerateInitialRoutes: (_) => state.inSession
          ? [MaterialPageRoute(builder: (_) => InitialRouter())]
          : [MaterialPageRoute(builder: (_) => AuthScreen())],
      initialRoute: '/',
    );
  }
}

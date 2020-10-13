import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_broccoli/cache.dart';
import 'package:smart_broccoli/models.dart';
import 'package:smart_broccoli/src/auth/auth_screen.dart';
import 'package:smart_broccoli/src/auth/init_page.dart';
import 'package:smart_broccoli/src/quiz/lobby.dart';
import 'package:smart_broccoli/src/quiz/quiz.dart';
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
  bool inSession;

  @override
  Widget build(BuildContext context) {
    AuthStateModel state = Provider.of<AuthStateModel>(context, listen: true);
    if (inSession != state.inSession) {
      if (inSession != null)
        mainNavigator.currentState
            .pushReplacementNamed(state.inSession ? '/home' : '/auth');
      inSession = state.inSession;
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Broccoli',
      theme: SmartBroccoliTheme.themeData,
      routes: {
        '/auth': (context) => AuthScreen(),
        '/home': (context) => InitialRouter(),
        '/take_quiz': (context) => TakeQuiz(),
        '/lobby': (context) => StartLobby()
      },
      navigatorKey: mainNavigator,
      // initialRoute: state.inSession ? '/home' : '/auth',
      initialRoute: '/lobby',
    );
  }
}

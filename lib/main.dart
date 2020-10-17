import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_broccoli/cache.dart';
import 'package:smart_broccoli/models.dart';
import 'package:smart_broccoli/src/about/acknowledgements.dart';
import 'package:smart_broccoli/theme.dart';

import 'src/about/about.dart';
import 'src/auth/auth_screen.dart';
import 'src/auth/init_page.dart';
import 'src/groups/group_create.dart';
import 'src/groups/group_list.dart';
import 'src/session/leaderboard.dart';
import 'src/session/lobby.dart';
import 'src/session/question.dart';
import 'src/quiz/take_quiz.dart';
import 'src/quiz/manage_quiz.dart';
import 'src/quiz_creator/question_creator.dart';
import 'src/quiz_creator/quiz_creator.dart';

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
  // Key for navigator
  final GlobalKey<NavigatorState> mainNavigator = GlobalKey<NavigatorState>();

  // Stores previous state about whether user's authenticated
  bool inSession;

  @override
  Widget build(BuildContext context) {
    // Get AuthStateModel
    AuthStateModel state = Provider.of<AuthStateModel>(context, listen: true);

    // On change of inSession
    if (inSession != state.inSession) {
      // Push route if app is initialised
      if (inSession != null)
        mainNavigator.currentState.pushNamedAndRemoveUntil(
            state.inSession ? '/home' : '/auth', (route) => false);
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
        '/manage_quiz': (context) => ManageQuiz(),
        '/lobby': (context) => QuizLobby(),
        '/question': (context) => QuizQuestion(),
        '/leaderboard': (context) => QuizLeaderboard(),
        '/about': (context) => AboutPage(),
        '/about/acknowledgements': (context) => AcknowledgementsPage(),
        '/group/home': (context) => GroupList(),
        '/group/create': (context) => GroupCreate(),
        '/quiz': (context) => QuizCreate(),
        '/quiz/question': (context) => QuestionCreate()
      },
      navigatorKey: mainNavigator,
      initialRoute: state.inSession ? '/home' : '/auth',
    );
  }
}

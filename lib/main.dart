import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_broccoli/router.dart';
import 'package:smart_broccoli/src/base.dart';
import 'package:smart_broccoli/src/local.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/models/session_model.dart';
import 'package:smart_broccoli/src/ui/shared/dialog.dart';
import 'package:smart_broccoli/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Local storage
  final KeyValueStore keyValueStore = await SharedPrefsKeyValueStore.create();
  final PictureStash picStash = await PictureStash.create();

  final AuthStateModel authStateModel = AuthStateModel(keyValueStore);
  final UserRepository userRepo = UserRepository(picStash);
  final UserProfileModel userProfileModel =
      UserProfileModel(keyValueStore, authStateModel, userRepo, picStash);
  final QuizCollectionModel quizCollectionModel =
      QuizCollectionModel(authStateModel, picStash);
  final GroupRegistryModel groupRegistryModel =
      GroupRegistryModel(authStateModel, userRepo, quizCollectionModel);
  final GameSessionModel gameSessionModel =
      GameSessionModel(authStateModel, quizCollectionModel);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authStateModel),
        ChangeNotifierProxyProvider<AuthStateModel, UserProfileModel>(
          create: (_) => userProfileModel,
          update: (_, authModel, userModel) => userModel..authUpdated(),
        ),
        ChangeNotifierProxyProvider<AuthStateModel, QuizCollectionModel>(
          create: (_) => quizCollectionModel,
          update: (_, authModel, quizCollectionModel) =>
              quizCollectionModel..authUpdated(),
        ),
        ChangeNotifierProxyProvider<AuthStateModel, GroupRegistryModel>(
          create: (_) => groupRegistryModel,
          update: (_, authModel, groupRegistryModel) =>
              groupRegistryModel..authUpdated(),
        ),
        ChangeNotifierProxyProvider<AuthStateModel, GameSessionModel>(
          create: (_) => gameSessionModel,
          update: (_, authModel, gameSessionModel) =>
              gameSessionModel..authUpdated(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  /// Publish subscribe
  final PubSub pubSub;

  /// Takes a publish/subscribe
  MyApp() : this.pubSub = PubSub();

  @override
  State createState() => _MyAppState();
}

/// Main entrance class
class _MyAppState extends State<MyApp> {
  /// Router
  final FluroRouter router;

  // Key for navigator
  final GlobalKey<NavigatorState> _mainNavigatorKey =
      GlobalKey<NavigatorState>();

  // Stores previous state about whether user's authenticated
  bool inSession;

  /// Constructor
  _MyAppState() : router = BroccoliRouter().router;

  @override
  void initState() {
    super.initState();
    widget.pubSub
        .subscribe(PubSubTopic.ROUTE, (routeArgs) => navigate(routeArgs));
    Provider.of<GameSessionModel>(context, listen: false).refreshSession();
  }

  /// Navigate to route
  Future<void> navigate(RouteArgs routeArgs) async {
    switch (routeArgs.action) {
      case RouteAction.PUSH:
        _mainNavigatorKey.currentState.pushNamed(routeArgs.name);
        break;
      case RouteAction.POP:
        _mainNavigatorKey.currentState.pop();
        break;
      case RouteAction.POPALL:
        _mainNavigatorKey.currentState
            .pushNamedAndRemoveUntil(routeArgs.name, (route) => false);
        break;
      case RouteAction.DIALOG_POPALL_SESSION:
        await showBasicDialog(_mainNavigatorKey.currentState.overlay.context,
            'The host aborted the session',
            title: 'Oof');
        continue popall_session;
      popall_session:
      case RouteAction.POPALL_SESSION:
        _mainNavigatorKey.currentState
            .popUntil((route) => !route.settings.name.startsWith('/session'));
        break;
      case RouteAction.REPLACE:
        _mainNavigatorKey.currentState.pushReplacementNamed(routeArgs.name);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get AuthStateModel
    AuthStateModel state = Provider.of<AuthStateModel>(context, listen: true);

    // On change of inSession
    if (inSession != state.inSession) {
      // Push route if app is initialised
      if (inSession != null)
        _mainNavigatorKey.currentState.pushNamedAndRemoveUntil(
            state.inSession ? '/take_quiz' : '/auth', (route) => false);
      Provider.of<GameSessionModel>(context, listen: false).refreshSession();
      inSession = state.inSession;
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Broccoli',
      theme: SmartBroccoliTheme.themeData,
      navigatorKey: _mainNavigatorKey,
      onGenerateRoute: router.generator,
      onGenerateInitialRoutes: (route) {
        return [router.generator(RouteSettings(name: route))];
      },
      initialRoute: state.inSession ? '/take_quiz' : '/auth',
    );
  }
}

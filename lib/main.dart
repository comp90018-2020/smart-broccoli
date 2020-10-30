import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:smart_broccoli/router.dart';
import 'package:smart_broccoli/src/background/background.dart';
import 'package:smart_broccoli/src/base.dart';
import 'package:smart_broccoli/src/local.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/theme.dart';
import 'package:workmanager/workmanager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  /// Initialise background services
  Workmanager.initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
  /// Schedule the background task
  /// Default is 15 minutes per refresh
  Workmanager.registerPeriodicTask(
    "1",
    "backgroundReading",
    initialDelay: Duration(seconds: 20),
  );



  // Communication
  final PubSub pubSub = PubSub();

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
      ],
      child: MyApp(pubSub),
    ),
  );
}

class MyApp extends StatefulWidget {
  /// Publish subscribe
  final PubSub pubSub;

  /// Takes a publish/subscribe
  MyApp(this.pubSub);

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
  }

  /// Navigate to route
  void navigate(RouteArgs routeArgs) {
    if (routeArgs.routeAction == RouteAction.POPALL) {
      _mainNavigatorKey.currentState
          .pushNamedAndRemoveUntil(routeArgs.routeName, (route) => false);
    } else if (routeArgs.routeAction == RouteAction.REPLACE) {
      _mainNavigatorKey.currentState.pushReplacementNamed(routeArgs.routeName);
    } else {
      _mainNavigatorKey.currentState.pushNamed(routeArgs.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    _checkPermissions();
    // Get AuthStateModel
    AuthStateModel state = Provider.of<AuthStateModel>(context, listen: true);

    // On change of inSession
    if (inSession != state.inSession) {
      // Push route if app is initialised
      if (inSession != null)
        _mainNavigatorKey.currentState.pushNamedAndRemoveUntil(
            state.inSession ? '/take_quiz' : '/auth', (route) => false);
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

/// A temporary permission checker
/// It works as intended so far
_checkPermissions() async {
  LocationPermission permission = await Geolocator.checkPermission();

  if (permission != LocationPermission.always) {
    await Geolocator.openAppSettings();
  }
}

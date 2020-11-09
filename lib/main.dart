import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:smart_broccoli/router.dart';
import 'package:smart_broccoli/src/background/background.dart';
import 'package:smart_broccoli/src/background/background_calendar.dart';
import 'package:smart_broccoli/src/base.dart';
import 'package:smart_broccoli/src/base/firebase.dart';
import 'package:smart_broccoli/src/base/firebase_session_handler.dart';
import 'package:smart_broccoli/src/local.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui/shared/dialog.dart';
import 'package:smart_broccoli/theme.dart';
import 'package:workmanager/workmanager.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Location, calendar, storage locations
  await _checkPermissions();

  // Save calendar (since calendar does not work in background)
  BackgroundCalendar.saveCalendarData();

  /// Initialise background services
  Workmanager.initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );

  // Cancel all ongoing background tasks upon running the app
  await Workmanager.cancelAll();

  /// Schedule the background task
  /// Default is 15 minutes per refresh
  Workmanager.registerPeriodicTask("1", "backgroundReading",
      initialDelay: Duration(seconds: 5),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
        requiresDeviceIdle: false,
      ));

  // Local storage
  final KeyValueStore keyValueStore = await SharedPrefsKeyValueStore.create();
  final PictureStash picStash = await PictureStash.create();

  final AuthStateModel authStateModel = AuthStateModel(keyValueStore);
  final UserRepository userRepo = UserRepository(picStash);
  final UserProfileModel userProfileModel =
      UserProfileModel(keyValueStore, authStateModel, picStash);
  final QuizCollectionModel quizCollectionModel =
      QuizCollectionModel(authStateModel, picStash);
  final GroupRegistryModel groupRegistryModel =
      GroupRegistryModel(authStateModel, userRepo, quizCollectionModel);
  final GameSessionModel gameSessionModel =
      GameSessionModel(authStateModel, quizCollectionModel, userRepo);

  final LocalNotification localNotification = LocalNotification();
  await Firebase.initializeApp();
  FirebaseNotification.initialise(localNotification);

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
    widget.pubSub
        .subscribe(PubSubTopic.SESSION_START, _handleNotificationSelection);

    // Refresh user sessions on startup
    Provider.of<GameSessionModel>(context, listen: false)
        .refreshSession()
        .catchError((_) => null);
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
      case RouteAction.POP_LEADERBOARD:
        _mainNavigatorKey.currentState
            .popUntil((route) => route.settings.name != '/session/leaderboard');
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
        // refresh quiz information as user has just left session
        Provider.of<QuizCollectionModel>(context, listen: false)
            .refreshAvailableQuizzes(refreshIfLoaded: true)
            .catchError((_) => null);
        Provider.of<QuizCollectionModel>(context, listen: false)
            .refreshCreatedQuizzes(refreshIfLoaded: true)
            .catchError((_) => null);
        break;
      case RouteAction.REPLACE:
        _mainNavigatorKey.currentState.pushReplacementNamed(routeArgs.name);
        break;
      case RouteAction.REPLACE_ALL:
        _mainNavigatorKey.currentState
            .pushNamedAndRemoveUntil(routeArgs.name, (route) => false);
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
      if (inSession != null) {
        _mainNavigatorKey.currentState.pushNamedAndRemoveUntil(
            state.inSession ? '/take_quiz' : '/auth', (route) => false);
        // Refresh sessions, note that refreshSession returns immediately
        // when the user is not authenticated
        Provider.of<GameSessionModel>(context, listen: false)
            .refreshSession()
            .catchError((_) => null);
      }
      inSession = state.inSession;
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Broccoli',
      theme: SmartBroccoliTheme.themeData,
      navigatorKey: _mainNavigatorKey,
      onGenerateRoute: router.generator,
      onGenerateInitialRoutes: (String route) {
        if (route.contains("session"))
          return [
            router.generator(RouteSettings(name: '/take_quiz')),
            router.generator(RouteSettings(name: route))
          ];
        return [router.generator(RouteSettings(name: route))];
      },
      initialRoute: getInitialRoute(inSession),
    );
  }

  // Handles startup
  String getInitialRoute(bool inSession) {
    if (!inSession) return '/auth';
    // If there the user has clicked on a notification
    var startMessage = FirebaseSessionHandler().getSessionStartMessage();
    if (startMessage == null) return '/take_quiz';
    return '/session/start/quiz/${startMessage.quizId}';
  }

  // Handle when notification is clicked
  void _handleNotificationSelection(dynamic content) {
    Navigator.of(_mainNavigatorKey.currentContext)
        .pushNamed("/session/start/quiz/$content")
        .catchError((error) {
      throw Exception(error);
    });
  }
}

/// A permission checker
_checkPermissions() async {
  await Geolocator.requestPermission();
  var statusCal = await Permission.calendar.status;
  var statusStorage = await Permission.storage.status;
  var statusLocation = await Permission.locationAlways.status;
  if (statusCal.isUndetermined) await Permission.calendar.request();
  if (statusStorage.isUndetermined) await Permission.storage.request();
  if (statusLocation.isUndetermined) await Permission.location.request();
}

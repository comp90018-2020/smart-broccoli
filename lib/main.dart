import 'dart:collection';

import 'package:device_calendar/device_calendar.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:smart_broccoli/router.dart';
import 'package:smart_broccoli/src/background/background.dart';
import 'package:smart_broccoli/src/background_database.dart';
import 'package:smart_broccoli/src/base.dart';
import 'package:smart_broccoli/src/local.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/theme.dart';
import 'package:workmanager/workmanager.dart';

// Device Calendar Plugin
DeviceCalendarPlugin deviceCalendarPlugin;

List<Event> events = [];

final Map<String, Object> inputMap = {};

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _checkPermissions();

  await _saveCalendarData();

  /// Initialise background services
  Workmanager.initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
  // Cancel all ongoing background tasks upon running the app
  await Workmanager.cancelAll();

  inputMap['cal'] = deviceCalendarPlugin;

  /// Schedule the background task
  /// Default is 15 minutes per refresh
  Workmanager.registerPeriodicTask("1", "backgroundReading",
      initialDelay: Duration(seconds: 30),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
        requiresDeviceIdle: false,
      ));

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
  deviceCalendarPlugin = new DeviceCalendarPlugin();
  LocationPermission permission = await Geolocator.checkPermission();
  Result<bool> res = await deviceCalendarPlugin.hasPermissions();

  if (permission != LocationPermission.always || !res.data) {
    await deviceCalendarPlugin.requestPermissions();
    await Geolocator.requestPermission();
    await Geolocator.openAppSettings();
  }
}

/// This should only be run on release mode see
/// https://github.com/builttoroam/device_calendar/issues/217
_saveCalendarData() async {
  await BackgroundDatabase.init();
  await BackgroundDatabase.cleanEvent();

  List<Result<UnmodifiableListView<Event>>> e = [];
  List<Event> ev = [];
  deviceCalendarPlugin = new DeviceCalendarPlugin();
  var cal = await deviceCalendarPlugin.retrieveCalendars();
  List<Calendar> calendar = cal.data;
  print("Calendar" + calendar.toString() + "Length:" + calendar.length.toString());


  // Define the time frame
  var now = new DateTime.now();
  RetrieveEventsParams retrieveEventsParams = new RetrieveEventsParams(
      startDate: now, endDate: now.add(new Duration(days: 7)));
  // Find all events within 7 days
  for (var i = 0; i < calendar.length; i++) {
    print("ID i = " + i.toString() );
    print("Cal ID" + calendar[i].id.toString());
    e.add(await deviceCalendarPlugin.retrieveEvents(
        calendar[i].id, retrieveEventsParams));
  }

  for (var j = 0; j < e.length; j++) {
    if (e[j].isSuccess) {
      ev = ev + e[j].data.toList();
    } else {
      print(e[j].errorMessages);
    }
  }

  print("Events:" + ev.toString());

  for (var j = 0; j < ev.length; j++) {
    CalEvent calEvent = new CalEvent(
        id: j,
        start: ev[j].start.millisecondsSinceEpoch,
        end: ev[j].end.millisecondsSinceEpoch);

    await BackgroundDatabase.insertEvent(calEvent);
  }
  BackgroundDatabase.closeDB();
}

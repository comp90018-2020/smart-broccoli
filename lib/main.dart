import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_broccoli/router.dart';
import 'package:smart_broccoli/src/local.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final KeyValueStore _keyValueStore = await SharedPrefsKeyValueStore.create();
  final AuthStateModel _authStateModel = AuthStateModel(_keyValueStore);
  final UserRepository _userRepo = UserRepository();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => _authStateModel),
        ChangeNotifierProvider(
          create: (context) => GroupRegistryModel(_authStateModel, _userRepo),
        )
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
  final GlobalKey<NavigatorState> _mainNavigatorKey =
      GlobalKey<NavigatorState>();

  // Stores previous state about whether user's authenticated
  bool inSession;

  _MyAppState() {
    final router = FluroRouter();
    Routes.configureRoutes(router);
    Routes.router = router;
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
            state.inSession ? '/home' : '/auth', (route) => false);
      inSession = state.inSession;
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Broccoli',
      theme: SmartBroccoliTheme.themeData,
      navigatorKey: _mainNavigatorKey,
      onGenerateRoute: Routes.router.generator,
      onGenerateInitialRoutes: (route) {
        return [Routes.router.generator(RouteSettings(name: route))];
      },
      initialRoute: state.inSession ? '/home' : '/auth',
    );
  }
}

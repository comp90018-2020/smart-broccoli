import 'package:flutter/material.dart';
import 'package:fuzzy_broccoli/client-api/auth.dart';
import 'package:fuzzy_broccoli/client-api/user.dart';
import 'logged.dart';
import 'unlogged.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AuthModel authModel = await AuthModel.create();
  UserModel userModel = UserModel(authModel);

  runApp(MultiProvider(
    child: MyApp(),
    providers: [
      Provider(create: (context) => userModel),
      Provider(create: (context) => authModel)
    ],
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        routes: {
          '/': (context) => Unlogged(title: 'Before login'),
          '/home': (context) => Logged(title: 'After login')
        },
        initialRoute: Provider.of<AuthModel>(context, listen: false).inSession()
            ? '/home'
            : '/');
  }
}

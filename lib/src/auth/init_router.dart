import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:smart_broccoli/models.dart';
import 'package:smart_broccoli/src/auth/auth_screen.dart';
import 'package:smart_broccoli/src/shared/page.dart';

class InitialRouter extends StatefulWidget {
  @override
  _InitialRouterState createState() => _InitialRouterState();
}

class _InitialRouterState extends State<InitialRouter> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthStateModel>(
      builder: (context, state, child) {
        if (state.inSession)
          // placeholder: to be replaced by homescreen
          return CustomPage(
            title: 'Logged in',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: ListTile(
                    leading: Icon(Icons.info),
                    title: Text('This screen is just a placeholder'),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    child: Text('Token: ${state.token}'),
                  ),
                ),
                Spacer(),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: RaisedButton(
                      child: Text('Logout'),
                      onPressed: state.logout,
                    ),
                  ),
                ),
              ],
            ),
          );
        return AuthScreen();
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:smart_broccoli/theme.dart';

import 'login.dart';
import 'register.dart';

/// Use : The Login Screen provides an interface to verify the user and log them
/// into the application.
/// Type : Stateful Widget
/// Transitions: A form change from register to login and login to register
class AuthScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  void initState() {
    super.initState();
  }

  // Primary start up function
  @override
  Widget build(BuildContext context) {
    // Height of SizedBox for TabView (below)
    double tabViewHeight =
        MediaQuery.of(context).size.height - // Viewport height
            200 - // Logo container
            kToolbarHeight - // Toolbar height
            70; // Toolbar heading

    // Create a new Scaffold
    return new Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: <Widget>[
              // Title (logo/application name)
              LogoContainer(
                child: Center(
                    // child: Image(
                    //     image:
                    //         AssetImage('assets/images/Logo_Placeholder.png')),
                    ),
              ),

              // Tabs
              TabHolder(
                  margin: const EdgeInsets.only(top: 35, bottom: 35),
                  tabs: [Tab(text: "LOGIN"), Tab(text: "SIGN UP")]),

              // Tab contents
              FractionallySizedBox(
                widthFactor: 0.7,
                child: LimitedBox(
                  // Need to limit height of TabBarView
                  // Error will occur if height is not limited
                  maxHeight: tabViewHeight < 150 ? 150 : tabViewHeight,
                  child: TabBarView(children: [Login(), Register()]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

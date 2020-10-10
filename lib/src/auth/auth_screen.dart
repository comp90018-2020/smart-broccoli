import 'package:flutter/material.dart';
import 'package:smart_broccoli/src/auth/index_stack.dart';
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

  int _tabIndex = 0;

  // Primary start up function
  @override
  Widget build(BuildContext context) {
    // Create a new Scaffold
    return new Scaffold(
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
                  onTap: (index) {
                    setState(() {
                      _tabIndex = index;
                    });
                  },
                  margin: const EdgeInsets.only(top: 35, bottom: 35),
                  tabs: [Tab(text: "LOGIN"), Tab(text: "SIGN UP")]),

              // Tab contents
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: FractionallySizedBox(
                    widthFactor: 0.7,
                    child: AnimatedIndexedStack(
                        index: _tabIndex, children: [Login(), Register()])),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

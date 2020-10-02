import 'package:flutter/material.dart';
import 'login.dart';
import 'register.dart';
import 'index_stack.dart';

/// Use : The Login Screen provides an interface to verify the user and log them
/// into the application.
/// Type : Stateful Widget
/// Transitions: A form change from register to login and login to register
class AuthScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
  }

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
                    Container(
                        height: 200,
                        color: Colors.white,
                        child: Center(
                          child: Image(
                              image: AssetImage(
                                  'assets/images/Logo_Placeholder.png')),
                        )),

                    // Tabs
                    FractionallySizedBox(
                        widthFactor: 0.5,
                        child: Container(
                            margin: EdgeInsets.only(top: 35, bottom: 20),
                            decoration: BoxDecoration(
                                color: Color(0xFF82C785),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25))),
                            child: TabBar(
                              onTap: (value) {
                                setState(() {
                                  _tabIndex = value;
                                });
                              },
                              tabs: [
                                new Tab(
                                  text: "LOGIN",
                                ),
                                new Tab(
                                  text: "SIGN UP",
                                )
                              ],
                            ))),

                    // Tab contents
                    FractionallySizedBox(
                        widthFactor: 0.7,
                        child: AnimatedIndexedStack(
                          index: _tabIndex,
                          children: [Login(), Register()],
                        ))
                  ],
                ))));
  }
}

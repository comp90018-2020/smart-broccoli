import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fuzzy_broccoli/theme.dart';
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
  GlobalKey _registerKey = GlobalKey();
  GlobalKey _loginKey = GlobalKey();
  double _height = 0;

  // Tabs that are shown (in TabBarView)
  List<Widget> _tabs;

  @override
  void initState() {
    super.initState();

    // Initial tabs (to solve TabBarView unbounded height issue)
    // When the height of the register tabview child is retrieved,
    // swap the pages around and constrain the height
    // https://github.com/flutter/flutter/issues/29749
    // https://github.com/flutter/flutter/issues/54968
    _tabs = [
      Wrap(children: [
        Login(key: _loginKey),
        Visibility(
            visible: false,
            maintainState: true,
            maintainAnimation: true,
            maintainSize: true,
            child: Wrap(children: [Register(key: _registerKey)])),
      ]),
      Container()
    ];

    // Get height of register box
    SchedulerBinding.instance.addPostFrameCallback((_) {
      RenderBox _registerBox = _registerKey.currentContext.findRenderObject();
      RenderBox _loginBox = _loginKey.currentContext.findRenderObject();
      double maxHeight = max(_registerBox.size.height, _loginBox.size.height);

      if (_height != maxHeight) {
        setState(() {
          _height = maxHeight;
          _tabs = [Login(key: _loginKey), Register(key: _registerKey)];
        });
      }
    });
  }

  // Primary start up function
  @override
  Widget build(BuildContext context) {
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
                  margin: const EdgeInsets.only(top: 35, bottom: 20),
                  tabs: [Tab(text: "LOGIN"), Tab(text: "SIGN UP")]),

              // Tab contents
              FractionallySizedBox(
                widthFactor: 0.7,
                child: LimitedBox(
                  // Need to limit height of TabBarView
                  // Error will occur if height is not limited (see above)
                  maxHeight: _height == 0
                      ? MediaQuery.of(context).size.height
                      : _height,
                  child: TabBarView(children: _tabs),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

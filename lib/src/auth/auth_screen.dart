import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
  GlobalKey _key = GlobalKey();
  double _height = 0;

  @override
  void initState() {
    super.initState();

    // Get height
    SchedulerBinding.instance.addPostFrameCallback((_) {
      RenderBox _renderBox = _key.currentContext.findRenderObject();
      if (_height != _renderBox.size.height) {
        setState(() {
          _height = _renderBox.size.height;
        });
      }
    });
  }

  // Primary start up function
  @override
  Widget build(BuildContext context) {
    // Create a new Scaffold
    return new Scaffold(
        body: Stack(children: [
      // Shadow element to get height of register box
      // This only works because register is of static height
      // https://github.com/flutter/flutter/issues/29749
      // https://github.com/flutter/flutter/issues/54968
      Wrap(children: [
        Visibility(
          key: _key,
          child: Register(),
          visible: false,
          maintainState: true,
          maintainSize: true,
          maintainAnimation: true,
        )
      ]),
      SingleChildScrollView(
          child: DefaultTabController(
              length: 2,
              child: Column(children: <Widget>[
                // Title (logo/application name)
                Container(
                    height: 200,
                    color: Colors.white,
                    child: Center(
                      child: Image(
                          image:
                              AssetImage('assets/images/Logo_Placeholder.png')),
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
                  child: LimitedBox(
                      maxHeight: _height == 0
                          ? MediaQuery.of(context).size.height
                          : _height,
                      child: TabBarView(children: [Login(), Register()])),
                ),
              ]))),
    ]));
  }
}

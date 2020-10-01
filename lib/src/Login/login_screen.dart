import 'package:flutter/material.dart';
import './login.dart';
import './register.dart';

/// Use : The Login Screen provides an interface to verify the user and log them
/// into the application.
/// Type : Stateful Widget
/// Transitions: A form change from register to login and login to register
class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LoginScreenState();
}

///
enum FormType { login, register }

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
  }

  // Primary start up function
  @override
  Widget build(BuildContext context) {
    Login login = Login();
    Register register = Register();

    // Create a new Scaffold
    return new Scaffold(
        body: SingleChildScrollView(
            child: Column(children: <Widget>[
      // Build title (logo/application name)
      Container(
          height: 200,
          color: Colors.white,
          child: Center(
            child:
                Image(image: AssetImage('assets/images/Logo_Placeholder.png')),
          )),

      // Body
      FractionallySizedBox(
          widthFactor: 0.7,
          child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Container(
                      margin: EdgeInsets.only(top: 30, bottom: 16),
                      decoration: BoxDecoration(
                          color: Color(0xFF82C785),
                          borderRadius: BorderRadius.all(Radius.circular(25))),
                      child: TabBar(
                        tabs: [
                          new Tab(
                            text: "LOGIN",
                          ),
                          new Tab(
                            text: "SIGN UP",
                          )
                        ],
                      )),
                  SizedBox(
                    height: 300,
                    // Subtract the top
                    child: TabBarView(
                      children: [login, register],
                    ),
                  )
                ],
              ))

          // child: Column(
          //   children: [
          //     Container(
          //         child: TabBar(controller: _tabController, tabs: <Tab>[
          //       new Tab(
          //         text: "LOGIN",
          //       ),
          //       new Tab(
          //         text: "SIGN UP",
          //       )
          //     ])),
          //     TabBarView(controller: _tabController, children: [
          //       Expanded(child: Login()),
          //       Expanded(child: Register()),
          //     ]),
          //   ],
          // ),
          ),
    ])));
  }
}

// body: TabBarView(
//   children: [Login(), Register()],
// )),

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'client_api.dart';

class Unlogged extends StatefulWidget {
  Unlogged({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _UnloggedState createState() => _UnloggedState();
}

class _UnloggedState extends State<Unlogged> {
  void login() {
    Provider.of<AuthModel>(context, listen: false).join().then((s) {
      if (s) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(child: Text('Login as user'), onPressed: login)
          ],
        ),
      ),
    );
  }
}

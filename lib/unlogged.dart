import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'server.dart';

class Unlogged extends StatefulWidget {
  Unlogged({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _UnloggedState createState() => _UnloggedState();
}

class _UnloggedState extends State<Unlogged> {
  void login() {
    try {
      Provider.of<AuthModel>(context, listen: false).join().then((_) {
          Navigator.of(context).pushReplacementNamed('/home');
      });
    } catch(e) {
      // TODO: show dialog
    }
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

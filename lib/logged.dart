import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'client_api.dart';

class Logged extends StatefulWidget {
  Logged({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoggedState createState() => _LoggedState();
}

class _LoggedState extends State<Logged> {
  void logout() {
    Provider.of<AuthModel>(context, listen: false).logout().then((s) {
      if (s) {
        Navigator.of(context).pushReplacementNamed('/');
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
            FutureBuilder<int>(
                initialData: 0,
                builder: (context, snapshot) {
                  return Text('User Id: ' + snapshot.data.toString());
                },
                future: Provider.of<UserModel>(context, listen: false)
                    .getUser()
                    .then((user) => user.id)),
            FlatButton(child: Text('Logout as user'), onPressed: logout)
          ],
        ),
      ),
    );
  }
}

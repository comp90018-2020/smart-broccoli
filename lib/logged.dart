import 'package:flutter/material.dart';
import 'package:fuzzy_broccoli/client-api/auth.dart';
import 'package:fuzzy_broccoli/client-api/user.dart';
import 'package:provider/provider.dart';

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
                future:
                    Provider.of<UserModel>(context, listen: false).getUserId()),
            FlatButton(child: Text('Logout as user'), onPressed: logout)
          ],
        ),
      ),
    );
  }
}

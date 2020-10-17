import 'package:flutter/material.dart';
import 'package:smart_broccoli/theme.dart';

// import 'package:smart_broccoli/shared/page.dart';
// TODO FIX THIS IMPORT
import '../shared/page.dart';

// Login tab
class Profile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _ProfileState();
}

class _ProfileState extends State<Profile> {
  final TextEditingController _nameController = new TextEditingController();
  final TextEditingController _emailController = new TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  bool _isEdit = false;

  void _togglEdit() {
    setState(() {
      if (_isEdit) {
        _isEdit = !_isEdit;
      } else {
        _isEdit = !_isEdit;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: CustomPage(
      title: "Profile",
      hasDrawer: true,
      child: _profileStats(),
      appbarActions: [edit()],
    ));
  }

  Widget edit() {
    return FlatButton(
      child: Text("Edit"),
      onPressed: () {
        // do something
        _togglEdit();
      },
    );
  }

  Widget _profileStats() {
    if (_isEdit) {
      return new Stack(
        children: <Widget>[
          ProfileTheme.profileBackground(context),
          SingleChildScrollView(
            child: Container(
              child: Column(
                children: mainBody(
                  TextFormField(
                    controller: _nameController,
                  ),
                  TextFormField(
                    controller: _emailController,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return new Stack(
        children: <Widget>[
          ProfileTheme.profileBackground(context),
          SingleChildScrollView(
            child: Container(
              child: Column(
                children: mainBody(Text(_nameController.text), Text(_emailController.text)),
              ),
            ),
          ),
        ],
      );
    }
  }

  List<Widget> mainBody(Widget c1, Widget c2) {
    return <Widget>[
      SizedBox(height: 50),
      CircleAvatar(
        backgroundColor: Colors.black12,
      ),
      SizedBox(height: 50),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 50,
            width: 100,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black12,
                width: 2,
              ),
            ),
            child: Center(child: Text("Name")),
          ),
          Container(
            height: 50,
            width: 200,
            decoration: ProfileTheme.bd1(),
            child: Center(child: c1),
          )
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 50,
            width: 100,
            decoration: ProfileTheme.bd2(),
            child: Center(child: Text("Email")),
          ),
          Container(
            height: 50,
            width: 200,
            decoration: ProfileTheme.bd3(),
            child: Center(child: c2),
          )
        ],
      ),
    ];
  }
}

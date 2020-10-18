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

  void _toggleEdit() {
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
      child: Text(
        "Edit",
        style: ProfileTheme.appBarTS,
      ),
      onPressed: () {
        // do something
        _toggleEdit();
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
                    decoration: new InputDecoration(
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        onPressed: () => _nameController.clear(),
                        icon: Icon(Icons.clear),
                      ),
                    ),
                    controller: _nameController,
                  ),
                  TextFormField(
                    decoration: new InputDecoration(
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        onPressed: () => _emailController.clear(),
                        icon: Icon(Icons.clear),
                      ),
                    ),
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
                children: mainBody(
                  Text(
                    _nameController.text,
                    style: ProfileTheme.profileTS,
                  ),
                  Text(
                    _emailController.text,
                    style: ProfileTheme.profileTS,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  List<Widget> mainBody(Widget c1, Widget c2) {
    double height = MediaQuery.of(context).size.height;
    return <Widget>[
      SizedBox(height: height / 5.8),
      CircleAvatar(
        backgroundColor: Colors.black12,
        radius: height / 19,
      ),
      SizedBox(height: 50),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 50,
            width: 120,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black12,
                width: 2,
              ),
            ),
            child: Center(
                child: Text(
              "Name",
              style: ProfileTheme.profileTS,
            )),
          ),
          Container(
            height: 50,
            width: 250,
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
            width: 120,
            decoration: ProfileTheme.bd2(),
            child: Center(
                child: Text(
              "Email",
              style: ProfileTheme.profileTS,
            )),
          ),
          Container(
            height: 50,
            width: 250,
            decoration: ProfileTheme.bd3(),
            child: Center(child: c2),
          )
        ],
      ),
    ];
  }
}

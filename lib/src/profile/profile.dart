import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_broccoli/src/profile/promoted_profile.dart';
import 'package:smart_broccoli/src/profile/registered_profile.dart';
import '../shared/page.dart';

// Profile
class Profile extends StatefulWidget {
  // final bool isJoined;

  /// now you could have only 3 states, i.e
  /// 1. is a profile being registered?
  /// 2. is a profile being saved
  /// 3. Or is the profile already saved
  /// However I did it this way to allow for maximal flexibility

  ProfileType pType;

  Profile(this.pType);

  @override
  State<StatefulWidget> createState() => new _ProfileState();
}

enum ProfileType { Promoted, Registered }

class _ProfileState extends State<Profile> {
  final TextEditingController _nameController = new TextEditingController();
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Whether edit mode is activated
  bool _isEdit = false;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: CustomPage(
        title: "Profile",
        hasDrawer: true,

        // Save/edit
        appbarActions: [
          CupertinoButton(
            child: Text(_isEdit ? "Save" : "Edit",
                style: TextStyle(color: Colors.white)),
            onPressed: () {
              setState(() {
                _isEdit = !_isEdit;
              });
            },
          )
        ],
        child: SingleChildScrollView(
          child: Column(
            children: [
              profilePicture(),
              _formBody(),
              (widget.pType == ProfileType.Registered) ? _promote() : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _save() {
    return new SizedBox(
      width: 150,
      child:
          RaisedButton(onPressed: () => goToSave(), child: Text("Save User")),
    );
  }

  // Code here for best abstraction practices, don't inject widgets from few
  // parents above
  Widget _promote() {
    return new SizedBox(
      width: 150,
      child: RaisedButton(
          onPressed: () => goToPromoted(), child: Text("Promote User")),
    );
  }

  void goToSave() {
    // TODO provider update here

    if ((widget.pType == ProfileType.Registered)) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) =>
                Profile(ProfileType.Promoted)),
      );
    }
  }

  // Code to promote profile to a joined profile
  void goToPromoted() {
    // TODO provider update here

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => PromotedProfile()),
    );
  }

  // The picture
  Widget profilePicture() {
    return Stack(
      children: [
        Column(
          children: [
            // Green clip
            Container(
                color: Theme.of(context).backgroundColor,
                height: MediaQuery.of(context).size.height * 0.18),
            // White container which is half the width of the profile picture
            Container(color: Colors.white, height: 40),
          ],
        ),
        // Profile picture
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: CircleAvatar(
            backgroundColor: Colors.black12,
            radius: 40,
          ),
        ),
      ],
    );
  }

  // Body
  Widget _formBody() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Material(
        type: MaterialType.card,
        elevation: 3,
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: {0: FlexColumnWidth(0.3), 1: FlexColumnWidth(0.7)},
          border: TableBorder.all(width: 0.8, color: Colors.black12),
          children: [
            // Name
            nameTableRow(),
            // Email
            emailTableRow(),
            // pType
            (widget.pType == ProfileType.Registered)
                ? passwordTableRow()
                : TableRow(children: [Container(), Container()]),
          ],
        ),
      ),
    );
  }

  /// I can't find a more elegant way of abstracting the Table Rows away since
  /// These table rows need the edit varible.

  TableRow nameTableRow() {
    return TableRow(children: [
      _paddedCell(Text('NAME', style: TextStyle(color: Colors.black38)),
          padding: EdgeInsets.only(left: 16)),
      _paddedCell(
        TextFormField(
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              hintStyle: TextStyle(color: Colors.black38),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {},
              ),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: 'John Smith'),
          controller: _nameController,
        ),
        padding: EdgeInsets.only(left: 16),
      ),
    ]);
  }

  TableRow emailTableRow() {
    return TableRow(
      children: [
        _paddedCell(Text('EMAIL', style: TextStyle(color: Colors.black38)),
            padding: EdgeInsets.only(left: 16)),
        _paddedCell(
          TextFormField(
            textAlignVertical: TextAlignVertical.center,
            readOnly: true,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                hintStyle: TextStyle(color: Colors.black38),
                border: InputBorder.none,
                suffixIcon: Icon(IconData(0x20)),
                // A space
                focusedBorder: InputBorder.none,
                hintText: 'name@example.com'),
            controller: _emailController,
          ),
          padding: EdgeInsets.only(left: 16),
        ),
      ],
    );
  }

  TableRow passwordTableRow() {
    return TableRow(
      children: [
        _paddedCell(Text('Password', style: TextStyle(color: Colors.black38)),
            padding: EdgeInsets.only(left: 16)),
        _paddedCell(
          TextFormField(
            obscureText: true,
            textAlignVertical: TextAlignVertical.center,
            //readOnly: true,

            decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                hintStyle: TextStyle(color: Colors.black38),
                border: InputBorder.none,
                suffixIcon: Icon(IconData(0x20)),
                // A space
                focusedBorder: InputBorder.none,
                hintText: 'password'),
            controller: _passwordController,
          ),
          padding: EdgeInsets.only(left: 16),
        ),
      ],
    );
  }

  /// Creates a padded table cell
  Widget _paddedCell(Widget child,
          {EdgeInsetsGeometry padding = EdgeInsets.zero}) =>
      TableCell(
        child: Padding(padding: padding, child: Expanded(child: child)),
      );
}

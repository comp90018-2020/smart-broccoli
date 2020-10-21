import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_broccoli/src/ui/profile/promoted_profile.dart';
import 'package:smart_broccoli/src/ui/shared/page.dart';

// Profile
class Profile extends StatefulWidget {
  // final bool isJoined;

  /// now you could have only 3 states, i.e
  /// 1. is a profile being registered?
  /// 2. is a profile being saved
  /// 3. Or is the profile already saved
  /// However I did it this way to allow for maximal flexibility

  final ProfileType pType;

  Profile(this.pType);

  @override
  State<StatefulWidget> createState() => new _ProfileState();
}

enum ProfileType { Promoted, Registered, Registering }

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
  bool _hideIsEdit = false;

  @override
  void initState() {
    super.initState();
    if (widget.pType == ProfileType.Registering) {
      _isEdit = true;
      _hideIsEdit = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: CustomPage(
        title: "Profile",
        hasDrawer: true,

        // Save/edit
        appbarActions: !_hideIsEdit
            ? [
                CupertinoButton(
                  child: Text(_isEdit ? "Save" : "Edit",
                      style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    setState(() {
                      _isEdit = !_isEdit;
                    });
                  },
                )
              ]
            : [],
        child: SingleChildScrollView(
          child: Column(
            children: [
              profilePicture(), // _changePassword()
              _formBody(),

              _isEdit
                  ? (widget.pType == ProfileType.Promoted)
                      ? _changePassword()
                      : Container()
                  : (widget.pType == ProfileType.Registered ||
                          widget.pType == ProfileType.Registered)
                      ? _promote()
                      : Container(),
              SizedBox(
                height: 20,
              ),
              (widget.pType == ProfileType.Registering)
                  ? _promote()
                  : Container(),
              SizedBox(
                height: 20,
              ),
              widget.pType == ProfileType.Promoted
                  ? Text(
                      "Registered User",
                      textAlign: TextAlign.center,
                    )
                  : Text(
                      "registering lets you login from another device and create groups",
                      textAlign: TextAlign.center,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _changePassword() {
    return new SizedBox(
      width: 150,
      child: RaisedButton(
          onPressed: () => _showLoginFailedDialogue(),
          child: Text("Change Password")),
    );
  }

  // Code here for best abstraction practices, don't inject widgets from few
  // parents above
  Widget _promote() {
    return new SizedBox(
      width: 150,
      child: RaisedButton(
          onPressed: () => goToPromoted(), child: Text("Register User")),
    );
  }

  // Code to promote profile to a joined profile
  void goToPromoted() {
    // TODO provider update here
    if (ProfileType.Registering == widget.pType) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => PromotedProfile()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => Profile(ProfileType.Registering)),
      );
    }
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
            (widget.pType == ProfileType.Promoted ||
                    widget.pType == ProfileType.Registering)
                ? emailTableRow()
                : TableRow(children: [Container(), Container()]),
            (widget.pType == ProfileType.Registering)
                ? passwordTableRow(true)
                : TableRow(children: [Container(), Container()]),
            (widget.pType == ProfileType.Registering)
                ? passwordTableRow2(true)
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
          readOnly: !_isEdit,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              hintStyle: TextStyle(color: Colors.black38),
              suffixIcon: IconButton(
                icon: _isEdit ? Icon(Icons.clear) : Icon(null),
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
            readOnly: !_isEdit,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                hintStyle: TextStyle(color: Colors.black38),
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: _isEdit ? Icon(Icons.clear) : Icon(null),
                  onPressed: () {},
                ),
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

  TableRow passwordTableRow(bool show) {
    return TableRow(
      children: show
          ? [
              _paddedCell(
                  Text('Password', style: TextStyle(color: Colors.black38)),
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
                      suffixIcon: IconButton(
                        icon: _isEdit ? Icon(Icons.clear) : Icon(null),
                        onPressed: () {},
                      ),
                      // A space
                      focusedBorder: InputBorder.none,
                      hintText: 'password'),
                  controller: _passwordController,
                ),
                padding: EdgeInsets.only(left: 16),
              ),
            ]
          : [
              _paddedCell(
                TextFormField(
                  obscureText: true,
                  textAlignVertical: TextAlignVertical.center,
                  //readOnly: true,

                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      hintStyle: TextStyle(color: Colors.black38),
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: _isEdit ? Icon(Icons.clear) : Icon(null),
                        onPressed: () {},
                      ),
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

  TableRow passwordTableRow2(bool show) {
    return TableRow(
      children: show
          ? [
              _paddedCell(
                  Text('Confirm Password',
                      style: TextStyle(color: Colors.black38)),
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
                      suffixIcon: IconButton(
                        icon: _isEdit ? Icon(Icons.clear) : Icon(null),
                        onPressed: () {},
                      ),
                      // A space
                      focusedBorder: InputBorder.none,
                      hintText: 'Confirm password'),
                  controller: _passwordController,
                ),
                padding: EdgeInsets.only(left: 16),
              ),
            ]
          : [
              _paddedCell(
                TextFormField(
                  obscureText: true,
                  textAlignVertical: TextAlignVertical.center,
                  //readOnly: true,

                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      hintStyle: TextStyle(color: Colors.black38),
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: _isEdit ? Icon(Icons.clear) : Icon(null),
                        onPressed: () {},
                      ),
                      // A space
                      focusedBorder: InputBorder.none,
                      hintText: 'Confirm password'),
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

  void _showLoginFailedDialogue() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Center(
          child: Text("Change Password"),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Material(
                type: MaterialType.card,
                child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: {
                    0: FlexColumnWidth(0.3),
                    1: FlexColumnWidth(0.7)
                  },
                  border: TableBorder.all(width: 0.8, color: Colors.black12),
                  children: [
                    passwordTableRow(false),
                    passwordTableRow2(false),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text("Submit"),
            onPressed: () => {},
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }
}

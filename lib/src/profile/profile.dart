import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../shared/page.dart';

// Profile
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
            children: [profilePicture(), _formBody()],
          ),
        ),
      ),
    );
  }

  // The picture
  Widget profilePicture() {
    return Stack(
      children: [
        Column(
          children: [
            Container(
                color: Theme.of(context).backgroundColor,
                height: MediaQuery.of(context).size.height * 0.18),
            Container(color: Colors.white, height: 40),
          ],
        ),
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
            TableRow(children: [
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
            ]),
            // Email
            TableRow(children: [
              _paddedCell(
                  Text('EMAIL', style: TextStyle(color: Colors.black38)),
                  padding: EdgeInsets.only(left: 16)),
              _paddedCell(
                TextFormField(
                  textAlignVertical: TextAlignVertical.center,
                  readOnly: true,
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      hintStyle: TextStyle(color: Colors.black38),
                      border: InputBorder.none,
                      suffixIcon: Icon(IconData(0x20)), // A space
                      focusedBorder: InputBorder.none,
                      hintText: 'name@example.com'),
                  controller: _emailController,
                ),
                padding: EdgeInsets.only(left: 16),
              ),
            ])
          ],
        ),
      ),
    );
  }

  /// Creates a padded table cell
  Widget _paddedCell(Widget child,
          {EdgeInsetsGeometry padding = EdgeInsets.zero}) =>
      TableCell(
        child: Padding(padding: padding, child: Expanded(child: child)),
      );
}

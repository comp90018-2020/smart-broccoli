import 'package:flutter/material.dart';
import 'package:smart_broccoli/src/shared/tabbed_page.dart';

/// Group list page
class GroupList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _GroupListState();
}

class _GroupListState extends State<GroupList> {
  // Current tab
  int tab = 0;

  // Groups (should get from provider instead)
  List<String> groups = ["Biology", "Chemistry", "Physics"];

  @override
  Widget build(BuildContext context) {
    return new CustomTabbedPage(
      title: "Groups",
      tabs: [Tab(text: "JOINED"), Tab(text: "CREATED")],
      hasDrawer: true,
      secondaryBackgroundColour: true,

      // Handle tab tap
      tabTap: (value) {
        setState(() {
          tab = value;
        });
      },

      // Tabs
      tabViews: [buildGroupList(groups), buildGroupList(groups)],

      // Action buttons
      floatingActionButton: tab == 0
          ? FloatingActionButton.extended(
              onPressed: () {},
              label: Text('JOIN GROUP'),
              icon: Icon(Icons.add),
            )
          : FloatingActionButton.extended(
              onPressed: () {},
              label: Text('CREATE GROUP'),
              icon: Icon(Icons.group_add)),
    );
  }

  // Builds a list of groups
  Widget buildGroupList(List<String> groups) {
    return FractionallySizedBox(
      widthFactor: 0.85,
      child: ListView.separated(
          itemCount: groups.length,
          padding: EdgeInsets.symmetric(vertical: 16.0),
          itemBuilder: (context, index) {
            return ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              onTap: () {},
              title: Text(
                groups[index],
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            );
          },
          separatorBuilder: (context, index) {
            return Divider(color: Colors.white);
          }),
    );
  }

  // void joinDialog() {
  //   return showDialog(
  //       context: context,
  //       builder: (context) {
  //         return AlertDialog(
  //           title: Text("Create New Group"),
  //           content: TextField(
  //             controller: cController,
  //             decoration: const InputDecoration(
  //               labelText: 'Name for your group',
  //             ),
  //           ),
  //           actions: <Widget>[
  //             MaterialButton(
  //                 elevation: 5.0,
  //                 child: Text("Cancel"),
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                 }),
  //             MaterialButton(
  //                 elevation: 5.0,
  //                 child: Text("Create"),
  //                 onPressed: () {
  //                   Navigator.of(context).pop(cController.text.toString());
  //                 })
  //           ],
  //         );
  //       });
  // }

//       return showDialog(
//           context: context,
//           builder: (context) {
//             return AlertDialog(
//               title: Text("Join group"),
//               content: TextField(
//                 controller: cController,
//                 decoration: const InputDecoration(
//                   labelText: 'Name of the group',
//                 ),
//               ),
//               actions: <Widget>[
//                 MaterialButton(
//                     elevation: 5.0,
//                     child: Text("Cancel"),
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                     }),
//                 MaterialButton(
//                     elevation: 5.0,
//                     child: Text("Join"),
//                     onPressed: () {
//                       Navigator.of(context).pop(cController.text.toString());
//                     })
//               ],
//             );
//           });
}

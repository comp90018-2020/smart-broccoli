import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_broccoli/models.dart';

import '../shared/tabbed_page.dart';

/// Group list page
class GroupList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _GroupListState();
}

class _GroupListState extends State<GroupList> {
  // Current tab
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    Provider.of<GroupRegistryModel>(context, listen: false)
        .refreshJoinedGroups();
    Provider.of<GroupRegistryModel>(context, listen: false)
        .refreshCreatedGroups();
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
      tabViews: [
        Consumer<GroupRegistryModel>(
          builder: (context, registry, child) =>
              buildGroupList(registry.joinedGroups),
        ),
        Consumer<GroupRegistryModel>(
          builder: (context, registry, child) =>
              buildGroupList(registry?.createdGroups),
        )
      ],

      // Action buttons
      floatingActionButton: tab == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                joinDialog().then((value) => {print(value)});
              },
              label: Text('JOIN GROUP'),
              icon: Icon(Icons.add),
            )
          : FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).pushNamed('/group/create');
              },
              label: Text('CREATE GROUP'),
              icon: Icon(Icons.group_add),
            ),
    );
  }

  // Builds a list of groups
  Widget buildGroupList(List<Group> groups) {
    return FractionallySizedBox(
      widthFactor: 0.85,
      child: ListView.builder(
        itemCount: groups.length,
        padding: EdgeInsets.symmetric(vertical: 16.0),
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              dense: true,
              onTap: () {},
              title: Text(
                groups[index].name,
                style: TextStyle(fontSize: 16),
              ),
              // subtitle: groups[index].role == GroupRole.OWNER
              //     ? Row(children: [
              //         Icon(Icons.person),
              //         Text('${groups[index].members.length} members')
              //       ])
              //     : Row(children: [
              //         Icon(Icons.assignment),
              //         Text('{n} incomplete self-paced quizzes')
              //       ]),
            ),
          );
        },
      ),
    );
  }

  /// The join group dialog
  Future<String> joinDialog() async {
    TextEditingController controller = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Join group"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Name of group',
              prefixIcon: Icon(Icons.people),
            ),
          ),
          actions: <Widget>[
            TextButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            TextButton(
              child: Text("Join"),
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
            )
          ],
        );
      },
    );
  }
}

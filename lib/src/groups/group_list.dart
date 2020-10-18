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
        .refreshJoinedGroups(withMembers: true);
    Provider.of<GroupRegistryModel>(context, listen: false)
        .refreshCreatedGroups(withMembers: true);
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
              buildGroupList(registry.createdGroups),
        )
      ],

      // Action buttons
      floatingActionButton: tab == 0
          ? FloatingActionButton.extended(
              onPressed: _joinGroup,
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
        itemBuilder: (context, i) {
          return Card(
            child: ListTile(
              dense: true,
              onTap: () {},
              title: Text(
                groups[i].name,
                style: TextStyle(fontSize: 16),
              ),
              subtitle: groups[i].members == null
                  ? null
                  : Row(
                      children: [
                        Icon(Icons.person),
                        Text('${groups[i].members.length} member'
                            '${groups[i].members.length > 1 ? "s" : ""}'),
                      ],
                    ),
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
            onSubmitted: (_) => Navigator.of(context).pop(controller.text),
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

  void _joinGroup() async {
    final String groupName = await joinDialog();
    if (groupName == "") return;
    try {
      await Provider.of<GroupRegistryModel>(context, listen: false)
          .joinGroup(name: groupName);
    } on GroupNotFoundException {
      _showUnsuccessful("Group does not exist: $groupName");
    } on AlreadyInGroupException {
      _showUnsuccessful("Already a member of group: $groupName");
    } catch (err) {
      _showUnsuccessful("Something went wrong");
    }
  }

  void _showUnsuccessful(String text) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Cannot join"),
        content: Text(text),
        actions: [
          TextButton(
            child: Text("OK"),
            onPressed: Navigator.of(context).pop,
          ),
        ],
      ),
    );
  }
}

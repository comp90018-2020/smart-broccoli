import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui/shared/dialog.dart';
import 'package:smart_broccoli/src/ui/shared/no_content_place_holder.dart';
import 'package:smart_broccoli/src/ui/shared/tabbed_page.dart';

/// Group list page
class GroupList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _GroupListState();
}

class _GroupListState extends State<GroupList> {
  // Current tab
  int tab = 0;



  @override
  void didChangeDependencies() {
    Provider.of<GroupRegistryModel>(context, listen: false)
        .refreshJoinedGroups();
    Provider.of<GroupRegistryModel>(context, listen: false)
        .refreshCreatedGroups();
    super.didChangeDependencies();
  }

  void initState() {
    super.initState();
    Provider.of<UserProfileModel>(context, listen: false)
        .getUser(forceRefresh: true)
        .catchError((_) => null);
  }



  @override
  Widget build(BuildContext context) {
      ///Checking whether user is registered, and adding only relevant tabs
      return Consumer<UserProfileModel>(
          builder: (context, profile, child) {
            print("here");

            return CustomTabbedPage(
              title: "Groups",
              ///Hiding tab for unregistered user
              tabs: profile.user.type != UserType.UNREGISTERED ? [Tab(text: "JOINED"),Tab(text: "CREATED")] : [Tab(text: "JOINED")],
              hasDrawer: true,
              secondaryBackgroundColour: true,
              // Handle tab tap
              tabTap: (value) {
                setState(() {
                  tab = value;
                });
              },
              // Tabs
              tabViews: profile.user.type != UserType.UNREGISTERED ? [
                Consumer<GroupRegistryModel>(
                builder: (context, registry, child) =>
                registry.joinedGroups.length > 0 ?
                buildGroupList(registry.joinedGroups) :
                Column(children:[
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 300),
                    child: NoContentPlaceholder(parentWidget: widget,
                      text: "Seems like you are not part of any group yet️"),
                  )
                ]),
              ), Consumer<GroupRegistryModel>(
                  builder: (context, registry, child) =>
                      buildGroupList(registry.createdGroups),
                )

                ///Hiding tab for unregistered user
              ] : [Consumer<GroupRegistryModel>(
                builder: (context, registry, child) =>
                registry.joinedGroups.length > 0 ?
                buildGroupList(registry.joinedGroups) :
                Column(children:[
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 300),
                    child: NoContentPlaceholder(parentWidget: widget,
                      text: "Seems like you are not part of any group yet️"),
                  )
                ]),
              )],

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
      );
  }

  // Builds a list of groups
  Widget buildGroupList(List<Group> groups) => FractionallySizedBox(
        widthFactor: 0.85,
        child: ListView.builder(
          itemCount: groups.length,
          padding: EdgeInsets.symmetric(vertical: 16.0),
          itemBuilder: (context, i) => Card(
            child: ListTile(
              dense: true,
              onTap: () =>
                  Navigator.of(context).pushNamed('/group/${groups[i].id}'),
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
                        if (groups[i].defaultGroup) ...[
                          Spacer(),
                          Text('Default Group')
                        ]
                      ],
                    ),
            ),
          ),
        ),
      );

  /// The join group dialog
  Future<String> joinDialog() async {
    TextEditingController controller = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
      ),
    );
  }

  void _joinGroup() async {
    final String groupName = await joinDialog();
    if (groupName == null) return;
    try {
      await Provider.of<GroupRegistryModel>(context, listen: false)
          .joinGroup(name: groupName);
    } on GroupNotFoundException {
      showBasicDialog(context, "Group does not exist: $groupName");
    } on AlreadyInGroupException {
      showBasicDialog(context, "Already a member of group: $groupName");
    } catch (err) {
      showBasicDialog(context, "Something went wrong");
    }
  }
}

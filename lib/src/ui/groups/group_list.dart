import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui/shared/no_content_place_holder.dart';
import 'package:smart_broccoli/src/ui/shared/indicators.dart';
import 'package:smart_broccoli/src/ui/shared/tabbed_page.dart';

/// Group list page
class GroupList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _GroupListState();
}

class _GroupListState extends State<GroupList> {
  // Current tab
  int tab = 0;

  // Whether currently in joining operation
  bool _committed = false;

  @override
  void didChangeDependencies() {
    Provider.of<GroupRegistryModel>(context, listen: false)
        .getJoinedGroups(refreshIfLoaded: true)
        .catchError((_) => null);
    Provider.of<GroupRegistryModel>(context, listen: false)
        .getCreatedGroups(refreshIfLoaded: true)
        .catchError((_) => Null);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    ///Checking whether user is registered, and adding only relevant tabs
    return Consumer<UserProfileModel>(builder: (context, profile, child) {
      return FutureBuilder(
        future: profile.getUser(),
        builder: (context, snapshot) {
          log("Group list member future ${snapshot.toString()}");
          return CustomTabbedPage(
            title: "Groups",

            ///Hiding tab for unregistered user
            tabs: [
              Tab(text: "JOINED"),
              if (snapshot.hasData &&
                  snapshot.data.type != UserType.UNREGISTERED)
                Tab(text: "CREATED")
            ],
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
                builder: (context, registry, child) => FutureBuilder(
                  future: registry.getJoinedGroups(withMembers: true),
                  builder: (context, snapshot) {
                    log("Group list future ${snapshot.toString()}");
                    if (snapshot.hasError)
                      return Center(
                          child: Text("An error has occurred, cannot load"));
                    if (snapshot.hasData && snapshot.data.length == 0)
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(35.0),
                            child: NoContentPlaceholder(
                              text:
                                  "Seems like you are not part of any group yet️",
                            ),
                          )
                        ],
                      );
                    if (snapshot.hasData)
                      return buildGroupList(
                          snapshot.data, registry.getGroupMembers);
                    return Center(child: LoadingIndicator(EdgeInsets.all(16)));
                  },
                ),
              ),
              if (snapshot.hasData &&
                  snapshot.data.type != UserType.UNREGISTERED)
                Consumer<GroupRegistryModel>(
                  builder: (context, registry, child) => FutureBuilder(
                    future: registry.getCreatedGroups(withMembers: true),
                    builder: (context, snapshot) {
                      if (snapshot.hasError)
                        return Center(
                            child: Text("An error has occurred, cannot load"));
                      // Should never happen
                      if (snapshot.hasData && snapshot.data.length == 0)
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(35.0),
                              child: NoContentPlaceholder(
                                text: "No groups available",
                              ),
                            )
                          ],
                        );
                      if (snapshot.hasData)
                        return buildGroupList(
                            snapshot.data, registry.getGroupMembers);
                      return Center(
                          child: LoadingIndicator(EdgeInsets.all(16)));
                    },
                  ),
                ),
            ],

            // Action buttons
            floatingActionButton: tab == 0
                ? Builder(
                    builder: (BuildContext context) =>
                        FloatingActionButton.extended(
                      onPressed: _committed ? null : () => _joinGroup(context),
                      label: Text('JOIN GROUP'),
                      icon: Icon(Icons.add),
                    ),
                  )
                : FloatingActionButton.extended(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/group/create');
                    },
                    label: Text('CREATE GROUP'),
                    icon: Icon(Icons.group_add),
                  ),
          );
        },
      );
    });
  }

  // Builds a list of groups
  Widget buildGroupList(List<Group> groups,
          Future<List<User>> Function(int) getGroupMembers) =>
      FractionallySizedBox(
        widthFactor: 0.8,
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
              subtitle: FutureBuilder(
                  future: getGroupMembers(groups[i].id),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return Container();
                    return Row(
                      children: [
                        Icon(Icons.person),
                        Text('${snapshot.data.length} member'
                            '${snapshot.data.length > 1 ? "s" : ""}'),
                        if (groups[i].defaultGroup) ...[
                          Spacer(),
                          Text('Default Group')
                        ]
                      ],
                    );
                  }),
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

  void _joinGroup(BuildContext context) async {
    final String groupName = await joinDialog();
    if (groupName == null) return;

    setState(() => _committed = true);
    await Provider.of<GroupRegistryModel>(context, listen: false)
        .joinGroup(name: groupName)
        .catchError((value) => showErrSnackBar(context, value));
    setState(() => _committed = false);
  }
}

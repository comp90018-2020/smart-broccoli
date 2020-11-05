import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models.dart';
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
  bool _isJoinedLoading = true;
  ChangeNotifier _joinedGroupNotifier = new ChangeNotifier();

  @override
  void didChangeDependencies() {
    Provider.of<GroupRegistryModel>(context, listen: false)
        .refreshJoinedGroups()
        .catchError((e) => showErrSnackBar(context, e.toString()));
    Provider.of<GroupRegistryModel>(context, listen: false)
        .refreshCreatedGroups()
        .catchError((e) => showErrSnackBar(context, e.toString()));
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    _joinedGroupNotifier.addListener(() => _isJoinedLoading = false);
  }

  @override
  Widget build(BuildContext context) => CustomTabbedPage(
        title: "Groups",
        tabs: [Tab(text: "JOINED"), Tab(text: "CREATED")],
        hasDrawer: true,
        secondaryBackgroundColour: true,

        // Handle tab tap
        tabTap: (value) {
          setState(() => tab = value);
        },

        // Tabs
        tabViews: [
          ChangeNotifierProvider(
              create: (_) => _joinedGroupNotifier,
              child: Consumer<GroupRegistryModel>(
                builder: (context, registry, child) =>
                    buildGroupList(registry.joinedGroups),
              )),
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

  // Builds a list of groups
  Widget buildGroupList(List<Group> groups) => FractionallySizedBox(
        widthFactor: 0.85,
        child: _isJoinedLoading
            ? loadingIndicator(20.0)
            : ListView.builder(
                itemCount: groups.length,
                padding: EdgeInsets.symmetric(vertical: 16.0),
                itemBuilder: (context, i) => Card(
                  child: ListTile(
                    dense: true,
                    onTap: () => Navigator.of(context)
                        .pushNamed('/group/${groups[i].id}'),
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
      showErrSnackBar(context, "Group does not exist: $groupName");
    } on AlreadyInGroupException {
      showErrSnackBar(context, "Already a member of group: $groupName");
    } catch (err) {
      showErrSnackBar(context, "Something went wrong");
    }
  }
}

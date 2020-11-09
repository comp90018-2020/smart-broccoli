import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui/shared/dialog.dart';

import 'members_tab.dart';
import 'quiz_tab.dart';

enum UserAction { LEAVE_GROUP, RENAME_GROUP, DELETE_GROUP }

class GroupMain extends StatefulWidget {
  final int groupId;

  GroupMain(this.groupId);

  @override
  State<StatefulWidget> createState() => new _GroupMain();
}

class _GroupMain extends State<GroupMain> with TickerProviderStateMixin {
  // Main tab controller
  TabController _controller;

  @override
  void didChangeDependencies() {
    Provider.of<GroupRegistryModel>(context, listen: false)
        .refreshGroup(widget.groupId, withMembers: true, withQuizzes: true);
    super.didChangeDependencies();
  }

  void initState() {
    super.initState();
    _controller = new TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,

        appBar: AppBar(
          bottom: new TabBar(
            controller: _controller,
            labelColor: Colors.white,
            indicator: UnderlineTabIndicator(),
            tabs: [
              Tab(child: Text("Quizzes")),
              Tab(child: Text("Members")),
            ],
          ),

          // Close button
          leading: new IconButton(
            icon: new Icon(Icons.close),
            enableFeedback: false,
            splashRadius: 20,
            onPressed: () => Navigator.of(context).pop(),
          ),

          // More actions
          actions: [
            Consumer<GroupRegistryModel>(builder: (context, registry, child) {
              Group group = registry.getGroupFromCache(widget.groupId);
              // Default groups cannot be renamed or deleted
              if (group == null ||
                  group.defaultGroup && group.role == GroupRole.OWNER)
                return Container();
              // Otherwise, show actions
              return PopupMenuButton(
                itemBuilder: (BuildContext context) =>
                    group.role == GroupRole.MEMBER
                        ? [
                            PopupMenuItem(
                              child: Text('Leave group'),
                              value: UserAction.LEAVE_GROUP,
                            )
                          ]
                        : [
                            PopupMenuItem(
                              child: Text('Rename group'),
                              value: UserAction.RENAME_GROUP,
                            ),
                            PopupMenuItem(
                              child: Text('Delete group'),
                              value: UserAction.DELETE_GROUP,
                            )
                          ],
                onSelected: (UserAction action) async {
                  switch (action) {
                    case UserAction.LEAVE_GROUP:
                      if (await _confirmLeaveGroup()) {
                        try {
                          await Provider.of<GroupRegistryModel>(context,
                                  listen: false)
                              .leaveGroup(group);
                          Navigator.of(context).pop();
                        } catch (e) {
                          await showBasicDialog(context, e.toString());
                        }
                      }
                      break;
                    case UserAction.RENAME_GROUP:
                      String newName = await _editNameDialogue();
                      if (newName == null) break;
                      await Provider.of<GroupRegistryModel>(context,
                              listen: false)
                          .renameGroup(group, newName)
                          .catchError(
                              (e) => showBasicDialog(context, e.toString()));
                      break;
                    case UserAction.DELETE_GROUP:
                      if (await showConfirmDialog(
                          context, "This cannot be undone",
                          title: "Confirm group deletion")) {
                        try {
                          await Provider.of<GroupRegistryModel>(context,
                                  listen: false)
                              .deleteGroup(group);
                          Navigator.of(context).pop();
                        } catch (e) {
                          showBasicDialog(context, e.toString());
                        }
                      }
                      break;
                    default:
                  }
                },
              );
            }),
          ],

          centerTitle: true,
          title: Consumer<GroupRegistryModel>(
            builder: (context, registry, child) {
              Group group = registry.getGroupFromCache(widget.groupId);
              return group == null ? Text('Group Name') : Text(group.name);
            },
          ),
        ),

        // Tabs
        body: TabBarView(
          controller: _controller,
          children: [
            QuizTab(widget.groupId),
            MembersTab(widget.groupId),
          ],
        ),
      );

  Future<bool> _confirmLeaveGroup() {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Confirm group departure"),
        content: Text("You will no longer be a member of this group"),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text("OK"),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<String> _editNameDialogue() async {
    TextEditingController controller = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Rename group"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'New name',
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
            child: Text("Rename"),
            onPressed: () {
              Navigator.of(context).pop(controller.text);
            },
          )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_broccoli/src/data.dart';

import 'package:smart_broccoli/src/models.dart';

import 'members_tab.dart';
import 'quiz_tab.dart';

enum UserAction { LEAVE_GROUP, DELETE_GROUP }

class GroupMain extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _GroupMain();
}

class _GroupMain extends State<GroupMain> with TickerProviderStateMixin {
  // Main tab controller
  TabController _controller;

  void initState() {
    super.initState();
    _controller = new TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          Consumer<GroupRegistryModel>(
            builder: (context, registry, child) => PopupMenuButton(
              itemBuilder: (BuildContext context) =>
                  registry.selectedGroup.role == GroupRole.MEMBER
                      ? [
                          PopupMenuItem(
                            child: Text('Leave group'),
                            value: UserAction.LEAVE_GROUP,
                          )
                        ]
                      : [
                          PopupMenuItem(
                            child: Text('Delete group'),
                            value: UserAction.DELETE_GROUP,
                          )
                        ],
              onSelected: (UserAction action) async {
                switch (action) {
                  case UserAction.LEAVE_GROUP:
                    try {
                      if (await _confirmLeaveGroup()) {
                        await Provider.of<GroupRegistryModel>(context,
                                listen: false)
                            .leaveSelectedGroup();
                        Navigator.of(context).pop();
                      }
                    } catch (_) {
                      _showErrorDialogue("Cannot leave group");
                    }
                    break;
                  case UserAction.DELETE_GROUP:
                    try {
                      if (await _confirmDeleteGroup()) {
                        await Provider.of<GroupRegistryModel>(context,
                                listen: false)
                            .deleteSelectedGroup();
                        Navigator.of(context).pop();
                      }
                    } catch (_) {
                      _showErrorDialogue("Cannot delete group");
                    }
                    break;
                  default:
                }
              },
            ),
          ),
        ],

        centerTitle: true,
        title: Consumer<GroupRegistryModel>(
            builder: (context, registry, child) =>
                registry.selectedGroup == null
                    ? Text('Group Name')
                    : Text(registry.selectedGroup.name)),
      ),

      // Tabs
      body: TabBarView(
        controller: _controller,
        children: [
          QuizTab(),
          MembersTab(),
        ],
      ),
    );
  }

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

  Future<bool> _confirmDeleteGroup() {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Confirm group deletion"),
        content: Text("This cannot be undone"),
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

  void _showErrorDialogue(String text) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Error"),
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

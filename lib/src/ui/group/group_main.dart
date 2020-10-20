import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          PopupMenuButton(
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                child: Text('Leave group'),
                value: UserAction.LEAVE_GROUP,
              ),
            ],
            onSelected: (UserAction action) async {
              switch (action) {
                case UserAction.LEAVE_GROUP:
                  try {
                    await Provider.of<GroupRegistryModel>(context,
                            listen: false)
                        .leaveSelectedGroup();
                    Navigator.of(context).pop();
                  } catch (_) {
                    _showCannotLeaveDialogue();
                  }
                  break;
                default:
              }
            },
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

  void _showCannotLeaveDialogue() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Error"),
        content: Text("Cannot leave group"),
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

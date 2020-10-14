import 'package:smart_broccoli/src/groups/group_list.dart';

import 'package:flutter/material.dart';
import 'package:smart_broccoli/src/shared/tabbed_page.dart';

GlobalKey _joinedKey = GlobalKey();
GlobalKey _createdKey = GlobalKey();

class GroupListContainer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _GroupListContainerState();
}

class _GroupListContainerState extends State<GroupListContainer> {
  // Tabs that are shown (in TabBarView)
  List<Widget> _tabs;

  @override
  void initState() {
    super.initState();

    _tabs = [
      GroupList(key: _joinedKey, name: 'joined'),
      GroupList(key: _createdKey, name: 'created')
    ];
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
          child: CustomTabbedPage(
        title: "GROUPS",
        tabs: [Tab(text: "JOINED"), Tab(text: "CREATED")],
        tabViews: _tabs,
        hasDrawer: true,
        // background: true,
        // customBackground: Container(
        //   child: ClipPath(
        //     clipper: BackgroundClipperMain(),
        //     child: Container(
        //       color: Theme.of(context).colorScheme.onBackground,
        //     ),
        //   ),
        // ),
      )),
    );
  }
}

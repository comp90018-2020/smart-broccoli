import 'package:smart_broccoli/src/groups/group-hp.dart';

import 'package:flutter/material.dart';
import 'package:smart_broccoli/src/shared/tabbed_page.dart';

GlobalKey _joinedKey = GlobalKey();
GlobalKey _createdKey = GlobalKey();

class GroupHpContainer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _GroupHpContainerState();
}

class _GroupHpContainerState extends State<GroupHpContainer> {
  // Tabs that are shown (in TabBarView)
  List<Widget> _tabs;

  @override
  void initState() {
    super.initState();

    _tabs = [
      GroupTab(key: _joinedKey, name: 'joined'),
      GroupTab(key: _createdKey, name: 'created')
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

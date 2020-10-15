import 'package:flutter/material.dart';
import 'package:smart_broccoli/src/shared/tabbed_page.dart';
import 'package:smart_broccoli/src/groups/group_list_container.dart';

class GroupList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _GroupListState();
}

class _GroupListState extends State<GroupList> {
  @override
  Widget build(BuildContext context) {
    return new CustomTabbedPage(
      title: "Groups",
      tabs: [Tab(text: "JOINED"), Tab(text: "CREATED")],
      tabViews: [
        GroupListContainer(name: 'joined'),
        GroupListContainer(name: 'created')
      ],
      hasDrawer: true,
      secondaryBackgroundColour: true,
      // background: true,
      // customBackground: Container(
      //   child: ClipPath(
      //     clipper: BackgroundClipperMain(),
      //     child: Container(
      //       color: Theme.of(context).colorScheme.onBackground,
      //     ),
      //   ),
      // ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_broccoli/src/shared/page.dart';
import 'package:smart_broccoli/theme.dart';

/// A tabbed page
class CustomTabbedPage extends StatelessWidget {
  /// Title of page
  final String title;

  /// Whether page has drawer
  final bool hasDrawer;

  /// Tabs (the toggle)
  final List<Tab> tabs;

  /// Tab views (the tabs/subpages)
  final List<Widget> tabViews;

  /// Constructs a custom page
  CustomTabbedPage(
      {@required this.title,
      @required this.tabs,
      @required this.tabViews,
      this.hasDrawer = false});

  @override
  Widget build(BuildContext context) {
    return CustomPage(
      title: this.title,
      hasDrawer: this.hasDrawer,
      child: DefaultTabController(
        length: tabs.length,
        child: Column(children: [
          // Add tabs
          PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight + 38),
              child: Container(
                  padding: const EdgeInsets.only(top: 26, bottom: 12),
                  child: TabHolder(
                    widthFactor: .8,
                    margin: EdgeInsets.zero,
                    tabs: tabs,
                  ))),
          // Tab body
          Expanded(
            child: TabBarView(
              children: tabViews,
            ),
          )
        ]),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_broccoli/src/shared/page.dart';
import 'package:smart_broccoli/theme.dart';

/// A tabbed page
class CustomTabbedPage extends CustomPage {
  /// Tabs (the toggle)
  final List<Tab> tabs;

  /// Tab views (the tabs/subpages)
  final List<Widget> tabViews;

  /// Constructs a custom page
  CustomTabbedPage(
      {@required String title,
      @required this.tabs,
      @required this.tabViews,
      bool hasDrawer = false})
      : super(
          title: title,
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
                  ),
                ),
              ),
              // Tab body
              Expanded(
                child: TabBarView(
                  children: tabViews,
                ),
              )
            ]),
          ),
          hasDrawer: hasDrawer,
        );
}

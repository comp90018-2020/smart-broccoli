import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_broccoli/src/shared/page.dart';
import 'package:smart_broccoli/theme.dart';

/// A tabbed page
class CustomTabbedPage extends CustomPage {
  /// Constructs a custom page
  ///
  /// Tabs (the toggle elements) and tab views (the tabs/subpages) should be in
  /// `tabs` and `tabViews` respectively.
  CustomTabbedPage(
      {@required String title,
      @required List<Tab> tabs,
      @required List<Widget> tabViews,
      hasDrawer = false,
      bool secondaryBackgroundColour = false,
      Widget background})
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
            background: background,
            secondaryBackgroundColour: secondaryBackgroundColour);
}

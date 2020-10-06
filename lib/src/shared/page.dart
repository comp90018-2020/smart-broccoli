import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_broccoli/theme.dart';

/// A page extending scaffold
/// Supports tabs, drawer
class CustomPage extends StatelessWidget {
  /// Title of page
  final String title;

  /// Tabs (the toggle)
  final List<Tab> tabs;

  /// Tab views (the tabs/subpages)
  final List<Widget> tabViews;

  /// Child
  final Widget child;

  /// Whether page has drawer
  final bool hasDrawer;

  /// Constructs a custom page
  CustomPage(
      {@required this.title,
      this.tabs,
      this.tabViews,
      this.child,
      this.hasDrawer = false});

  @override
  Widget build(BuildContext context) {
    // Whether page has tabs
    bool hasTabs = tabs.length > 0;

    // Cannot have both tabs and child
    assert(hasTabs || this.child != null);

    // Body of page
    Widget body = hasTabs
        ? Column(children: [
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
            Expanded(
                child: TabBarView(
              children: tabViews,
            ))
          ])
        // No tabs
        : child;

    // Material scaffold
    Scaffold scaffold = Scaffold(
        // Appbar
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Container(
              // Alter shadow: https://stackoverflow.com/questions/54554569
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(color: Colors.white, offset: const Offset(0, .2))
              ]),
              child: AppBar(
                title: Text(this.title),
                centerTitle: true,
                elevation: 0,
              )),
        ),

        // Drawer (or hamberger menu)
        drawer: hasDrawer
            ? Drawer(
                child: ListView(
                  // Important: Remove any padding from the ListView.
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    DrawerHeader(
                      child: Text(
                        'Drawer Header',
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.question_answer),
                      title: const Text('Take Quiz'),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: const Icon(Icons.edit),
                      title: const Text('Manage Quiz'),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: const Icon(Icons.people),
                      title: const Text('Groups'),
                      onTap: () {},
                    ),
                    Divider(),
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text('About'),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Sign out'),
                      onTap: () {},
                    ),
                  ],
                ),
              )
            : null,

        // Body of page
        body: body);

    // If there are tabs, need to return tab controller
    return hasTabs
        ? DefaultTabController(length: 2, child: scaffold)
        : scaffold;
  }
}

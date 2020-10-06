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
                    SizedBox(
                        height: 125,
                        child: DrawerHeader(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // User picture
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(100)),
                                width: 50,
                                height: 50,
                              ),
                              // Name/email
                              Expanded(
                                  child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 18),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('name',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1),
                                    Text('email',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2),
                                  ],
                                ),
                              )),
                              Icon(Icons.chevron_right, color: Colors.grey[700])
                            ],
                          ),
                        )),
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.question_answer),
                      title: Text('Take Quiz',
                          style:
                              TextStyle(color: Theme.of(context).primaryColor)),
                      onTap: () {},
                    ),
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.edit),
                      title: Text('Manage Quiz',
                          style:
                              TextStyle(color: Theme.of(context).primaryColor)),
                      onTap: () {},
                    ),
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.people),
                      title: Text('Groups',
                          style:
                              TextStyle(color: Theme.of(context).primaryColor)),
                      onTap: () {},
                    ),
                    Divider(),
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.info_outline),
                      title: Text('About',
                          style: TextStyle(color: Colors.grey[700])),
                      onTap: () {},
                    ),
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.exit_to_app),
                      title: Text('Sign out',
                          style: TextStyle(color: Colors.grey[700])),
                      trailing: const Icon(Icons.chevron_right),
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

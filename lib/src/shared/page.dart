import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A page extending scaffold
/// Supports tabs, drawer
class CustomPage extends StatelessWidget {
  /// Title of page
  final String title;

  /// Child
  final Widget child;

  /// Whether page has drawer
  final bool hasDrawer;

  /// Secondary background colour
  final bool secondaryBackgroundColour;

  /// Background overlay
  final List<Widget> background;

  /// AppBar leading widget
  final Widget appbarLeading;

  /// AppBar trailing widget
  final List<Widget> appbarActions;

  /// Floating action button
  final Widget floatingActionButton;

  /// Constructs a custom page
  CustomPage(
      {@required this.title,
      @required this.child,
      this.hasDrawer = false,
      this.background,
      this.secondaryBackgroundColour = false,
      this.appbarLeading,
      this.appbarActions,
      this.floatingActionButton});

  @override
  Widget build(BuildContext context) {
    // Dismiss keyboard when clicking outside
    // https://stackoverflow.com/questions/51652897
    Widget wrappedChild = GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: child,
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
    );

    return Scaffold(
      backgroundColor: this.secondaryBackgroundColour
          ? Theme.of(context).backgroundColor
          : Theme.of(context).colorScheme.onBackground,

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
              actions: appbarActions),
        ),
      ),

      // Drawer (or hamberger menu)
      drawer: hasDrawer
          ? Drawer(
              child: ListView(
                // Important: Remove any padding from the ListView.
                padding: EdgeInsets.zero,
                children: <Widget>[
                  SizedBox(
                    height: 130,
                    child: DrawerHeader(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  // User picture
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius:
                                            BorderRadius.circular(100)),
                                    width: 50,
                                    height: 50,
                                  ),
                                  // Name/email
                                  Expanded(
                                      child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                  Icon(Icons.chevron_right,
                                      color: Colors.grey[700])
                                ]),
                          ),
                          Expanded(child: Container())
                        ],
                      ),
                    ),
                  ),
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.question_answer),
                    title: Text('TAKE QUIZ',
                        style:
                            TextStyle(color: Theme.of(context).primaryColor)),
                    onTap: () {
                      if (ModalRoute.of(context).settings.name != '/take_quiz')
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            '/take_quiz', (route) => false);
                      else
                        Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.edit),
                    title: Text('MANAGE QUIZ',
                        style:
                            TextStyle(color: Theme.of(context).primaryColor)),
                    onTap: () {},
                  ),
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.people),
                    title: Text('GROUPS',
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
                    onTap: () {},
                  ),
                ],
              ),
            )
          : null,

      // Floating action button
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      // Body of page
      // https://stackoverflow.com/questions/54837854
      body: background == null
          ? wrappedChild
          : Stack(
              children: [...background, Positioned.fill(child: wrappedChild)],
            ),
    );
  }
}

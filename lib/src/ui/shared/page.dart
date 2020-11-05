import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/theme.dart';

/// A page extending scaffold
/// Supports tabs, drawer
class CustomPage extends StatelessWidget {
  /// Title of page
  final String title;

  /// Child
  final Widget child;

  /// Whether page has drawer
  final bool hasDrawer;

  /// Whether page is at top of screen
  final bool primary;

  /// Secondary background colour
  final bool secondaryBackgroundColour;

  /// Background overlay
  final List<Widget> background;

  /// AppBar leading widget
  final Widget appbarLeading;

  /// Whether to automatically imply leading if appbarLeading is false
  final bool automaticallyImplyLeading;

  /// AppBar trailing widget
  final List<Widget> appbarActions;

  /// Floating action button
  final Widget floatingActionButton;

  /// Constructs a custom page
  CustomPage(
      {@required this.title,
      @required this.child,
      this.hasDrawer = false,
      this.primary = true,
      this.background,
      this.secondaryBackgroundColour = false,
      this.appbarLeading,
      this.automaticallyImplyLeading = true,
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

      // At top
      primary: primary,

      // Appbar
      appBar: primary
          ? PreferredSize(
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
                  leading: appbarLeading,
                  automaticallyImplyLeading: automaticallyImplyLeading,
                  actions: appbarActions,
                ),
              ),
            )
          : null,

      // Drawer (or hamberger menu)
      drawer: hasDrawer
          ? Drawer(
              child: ListView(
                // Important: Remove any padding from the ListView.
                padding: EdgeInsets.zero,
                children: <Widget>[
                  Container(
                    // Margin adapted from drawer_header.dart
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top),
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        _navigateToNamed(context, '/profile');
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // User picture
                          Consumer<UserProfileModel>(
                            builder: (context, profile, child) => FutureBuilder(
                              future: Provider.of<UserProfileModel>(context)
                                  .getUserPicture(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<String> snapshot) {
                                return UserAvatar(
                                  snapshot.data,
                                  maxRadius: 30,
                                );
                              },
                            ),
                          ),
                          // Name/email
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 18),
                              child: Consumer<UserProfileModel>(
                                builder: (context, profile, child) =>
                                    FutureBuilder(
                                  future: profile.getUser(forceRefresh: false),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<User> snapshot) {
                                    return Wrap(
                                      direction: Axis.vertical,
                                      spacing: 2,
                                      children: snapshot.hasData
                                          ? [
                                              Text(snapshot.data.name,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1),
                                              Text(
                                                  snapshot.data.type ==
                                                          UserType.UNREGISTERED
                                                      ? "Unregistered"
                                                      : snapshot.data.email,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText2),
                                            ]
                                          : [
                                              Text('Unknown User',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1)
                                            ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          Icon(Icons.chevron_right, color: Colors.grey[700]),
                        ],
                      ),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.question_answer),
                    title: Text('TAKE QUIZ',
                        style: TextStyle(
                            color: Theme.of(context).primaryColorDark)),
                    onTap: () {
                      _navigateToNamed(context, '/take_quiz');
                    },
                  ),
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.edit),
                    title: Text('MANAGE QUIZ',
                        style: TextStyle(
                            color: Theme.of(context).primaryColorDark)),
                    onTap: () {
                      _navigateToNamed(context, '/manage_quiz');
                    },
                  ),
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.people),
                    title: Text('GROUPS',
                        style: TextStyle(
                            color: Theme.of(context).primaryColorDark)),
                    onTap: () {
                      _navigateToNamed(context, '/group/home');
                    },
                  ),
                  Divider(),
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.info_outline),
                    title: Text('About',
                        style: TextStyle(color: Colors.grey[700])),
                    onTap: () {
                      _navigateToNamed(context, '/about');
                    },
                  ),
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.exit_to_app),
                    title: Text('Sign out',
                        style: TextStyle(color: Colors.grey[700])),
                    onTap: Provider.of<AuthStateModel>(context, listen: false)
                        .logout,
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

  /// Navigate to named route
  void _navigateToNamed(context, routeName) {
    if (ModalRoute.of(context).settings.name != routeName)
      Navigator.of(context)
          .pushNamedAndRemoveUntil(routeName, (route) => false);
    else
      Navigator.pop(context);
  }
}

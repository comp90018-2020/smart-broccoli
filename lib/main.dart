import 'package:flutter/material.dart';
import 'package:smart_broccoli/src/shared/page.dart';
import 'package:smart_broccoli/theme.dart';

import 'src/auth/auth_screen.dart';

void main() => runApp(MyApp());

/// Main entrance class
class MyApp extends StatelessWidget {
  final items = List<String>.generate(10000, (i) => "Item $i");

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Smart Broccoli',
        theme: SmartBroccoliTheme().themeData,
        home: CustomPage(
          title: 'Page title',
          hasDrawer: true,
          tabs: [Tab(text: 'A'), Tab(text: 'B')],
          tabViews: [
            ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('${items[index]}'),
                );
              },
            ),
            Text('Page 2')
          ],
        ));
  }
}

import 'package:flutter/material.dart';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/ui/shared/tabbed_page.dart';
import 'package:smart_broccoli/src/ui/shared/quiz_container.dart';

class QuizTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _QuizTab();
}

class _QuizTab extends State<QuizTab> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        child: CustomTabbedPage(
          secondaryBackgroundColour: true,
          title: "YES",
          tabs: [Tab(text: "ALL"), Tab(text: "LIVE"), Tab(text: "SELF-PACED")],
          tabViews: [
            QuizContainer(
              [
                // placeholders
                Quiz.fromJson({'title': 'Foo', 'groupId': 1}),
                Quiz.fromJson({'title': 'Bar', 'groupId': 2}),
                Quiz.fromJson({'title': 'Baz', 'groupId': 3}),
              ],
              hiddenButton: true,
            ),
            QuizContainer(
              [
                // placeholders
                Quiz.fromJson({'title': 'Quick', 'groupId': 1}),
                Quiz.fromJson({'title': 'Brown', 'groupId': 2}),
                Quiz.fromJson({'title': 'Fox', 'groupId': 3}),
              ],
              hiddenButton: true,
            ),
            QuizContainer(
              [
                // placeholders
                Quiz.fromJson({'title': 'Over', 'groupId': 1}),
                Quiz.fromJson({'title': 'Lazy', 'groupId': 2}),
                Quiz.fromJson({'title': 'Dog', 'groupId': 3}),
              ],
              hiddenButton: true,
            ),
          ],
          hasDrawer: false,
          primary: false,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {},
            label: Text('CREATE QUIZ'),
            icon: Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

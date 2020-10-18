import 'package:flutter/material.dart';
import 'package:smart_broccoli/src/quiz/quiz_container.dart';
import 'package:smart_broccoli/src/shared/tabbed_page.dart';
import 'package:smart_broccoli/theme.dart';

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
            QuizContainer(['A', 'B', 'C', 'D'], hiddenButton: true),
            QuizContainer(['E', 'F', 'G', 'H'], hiddenButton: true),
            QuizContainer(['I', 'J', 'K', 'L'], hiddenButton: true),
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

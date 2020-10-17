import 'package:flutter/material.dart';
import 'package:smart_broccoli/src/quiz/quiz_container.dart';
import 'package:smart_broccoli/src/shared/tabbed_page.dart';
import 'package:smart_broccoli/theme.dart';

// GlobalKey _allKey = GlobalKey();
// GlobalKey _groupKey = GlobalKey();
// GlobalKey _selfKey = GlobalKey();

class QuizTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _QuizTab();
}

class _QuizTab extends State<QuizTab> {
  // Tabs that are shown (in TabBarView)
  List<Widget> _tabs;

  @override
  void initState() {
    super.initState();

    _tabs = [
      QuizContainer(['A', 'B', 'C', 'D']),
      QuizContainer(['E', 'F', 'G', 'H']),
      QuizContainer(['I', 'J', 'K', 'L']),
    ];
  }

  Widget createQuiz() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: RaisedButton(
        onPressed: () => {},
        shape: SmartBroccoliTheme.raisedButtonShape,
        child: Padding(
          padding: SmartBroccoliTheme.raisedButtonTextPadding,
          child: Text(
            "Create Quiz",
            style: TextStyle(fontSize: 13),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
          child: CustomTabbedPage(
        title: "YES",
        tabs: [Tab(text: "ALL"), Tab(text: "LIVE"), Tab(text: "SELF")],
        tabViews: _tabs,
        hasDrawer: false,
        hasAppBar: false,
        background: [groupBackground(false)],
      )),
    );
  }
}

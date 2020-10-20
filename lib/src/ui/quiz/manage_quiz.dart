import 'package:flutter/material.dart';
import 'package:smart_broccoli/theme.dart';

import 'package:smart_broccoli/src/ui/shared/quiz_container.dart';
import 'package:smart_broccoli/src/ui/shared/tabbed_page.dart';

/// Manage quiz page
class ManageQuiz extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _ManageQuizState();
}

class _ManageQuizState extends State<ManageQuiz> {
  // TODO: replace with provider inside build
  List<String> items = ["A", "B", "C", "D", "E", "F", "G", "H"];

  @override
  Widget build(BuildContext context) {
    // Somewhat wasteful to have multiple widgets, but that's how tabs work
    return CustomTabbedPage(
      title: "Manage Quiz",
      tabs: [Tab(text: "ALL"), Tab(text: "LIVE"), Tab(text: "SELF-PACED")],
      tabViews: [
        // All quizzes
        QuizContainer(items, header: _groupSelector(), hiddenButton: true),

        // Live quiz
        QuizContainer(items, header: _groupSelector(), hiddenButton: true),

        /// Self-paced quiz
        QuizContainer(items, header: _groupSelector(), hiddenButton: true),
      ],
      hasDrawer: true,
      secondaryBackgroundColour: true,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: Text('CREATE QUIZ'),
        icon: Icon(Icons.add),
      ),
    );
  }

  /// Quiz selection dropdown
  Widget _groupSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      constraints: BoxConstraints(maxWidth: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('GROUP',
              style: TextStyle(
                  color: SmartBroccoliColourScheme().onBackground,
                  fontSize: 16)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: DropdownButton(
                  underline: Container(),
                  onChanged: (_) {},
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(child: Center(child: Text('A')), value: 0),
                    DropdownMenuItem(child: Center(child: Text('B')), value: 1)
                  ],
                  value: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

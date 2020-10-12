import 'package:flutter/material.dart';
import 'package:smart_broccoli/src/quiz/quiz_build.dart';
import 'package:smart_broccoli/src/shared/tabbed_page.dart';
// import '../shared/background.dart';

class QuizTaker extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _QuizTakerState();
}

class _QuizTakerState extends State<QuizTaker> {
  @override
  Widget build(BuildContext context) {
    var items = getItems();

    return CustomTabbedPage(
      title: "Take Quiz",
      tabs: [Tab(text: "ALL"), Tab(text: "LIVE"), Tab(text: "SELF-PACED")],
      tabViews: [BuildQuiz(items), BuildQuiz(items), BuildQuiz(items)],
      hasDrawer: true,
      secondaryBackgroundColour: true,
      // background: Container(
      //   child: ClipPath(
      //     clipper: BackgroundClipperMain(),
      //     child: Container(
      //       color: Theme.of(context).colorScheme.onBackground,
      //     ),
      //   ),
      // ),
    );
  }

  /// Entry function for the different type of quizes
  /// Please change the output type
  /// Should default to "ALL"
  /// Type should be of type Key
  List<String> getItems() {
    print("NOT IMPLEMENTED");
    return ["A", "B", "C", "D", "E", "F", "G"];
  }
}

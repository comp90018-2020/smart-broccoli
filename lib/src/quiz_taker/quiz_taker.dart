import 'package:flutter/material.dart';
import 'package:smart_broccoli/src/quiz_taker/build_quiz.dart';
import 'package:smart_broccoli/src/shared/tabbed_page.dart';
import '../shared/background.dart';

GlobalKey _allKey = GlobalKey();
GlobalKey _groupKey = GlobalKey();
GlobalKey _selfKey = GlobalKey();

class QuizTaker extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _QuizTakerState();
}

class _QuizTakerState extends State<QuizTaker> {
  @override
  Widget build(BuildContext context) {
    return CustomTabbedPage(
      title: "YES",
      tabs: [Tab(text: "ALL"), Tab(text: "LIVE"), Tab(text: "SELF")],
      tabViews: [
        BuildQuiz(key: _allKey),
        BuildQuiz(key: _groupKey),
        BuildQuiz(key: _selfKey)
      ],
      hasDrawer: true,
      background: true,
      customBackground: Container(
        child: ClipPath(
          clipper: BackgroundClipperMain(),
          child: Container(
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../shared/tabbed_page.dart';
import 'quiz_container.dart';
import 'quiz_pin_box.dart';

/// Take quiz page
class TakeQuiz extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _TakeQuizState();
}

class _TakeQuizState extends State<TakeQuiz> {
  // Key for pin box
  final GlobalKey _buildQuizKey = GlobalKey();
  // Height of pin box
  double _height;

  // TODO: replace with provider inside build
  List<String> items = ["A", "B", "C", "D", "E", "F", "G", "H"];

  @override
  void initState() {
    super.initState();

    // Set _height
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RenderBox renderBox = _buildQuizKey.currentContext.findRenderObject();
      double pinBoxHeight = renderBox.size.height;
      if (pinBoxHeight != _height) {
        setState(() {
          _height = pinBoxHeight;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Somewhat wasteful to have multiple widgets, but that's how tabs work
    return CustomTabbedPage(
      title: "Take Quiz",
      tabs: [Tab(text: "ALL"), Tab(text: "LIVE"), Tab(text: "SELF-PACED")],
      tabViews: [
        // All quizzes
        QuizContainer(QuizPinBox(key: _buildQuizKey), items),

        // Live quiz
        QuizContainer(QuizPinBox(), items),

        /// Self-paced quiz has Text to fill the vertical space
        QuizContainer(
            ConstrainedBox(
                constraints: BoxConstraints(minHeight: _height ?? 175),
                child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Take a self-paced quiz...\nHave some fun',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ))),
            items)
      ],
      hasDrawer: true,
      secondaryBackgroundColour: true,
    );
  }
}

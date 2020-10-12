import 'package:flutter/material.dart';
import 'quiz_container.dart';
import 'quiz_pin_box.dart';
import 'package:smart_broccoli/src/shared/tabbed_page.dart';

/// Take/manage quiz page
class Quiz extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _QuizState();
}

class _QuizState extends State<Quiz> {
  // Key for pin box
  final GlobalKey _buildQuizKey = GlobalKey();
  // Height of pin box
  double _height;

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
    var items = getItems();

    // Somewhat wasteful to have multiple widgets, but that's how tabs work
    return CustomTabbedPage(
      title: "Take Quiz",
      tabs: [Tab(text: "ALL"), Tab(text: "LIVE"), Tab(text: "SELF-PACED")],
      tabViews: [
        BuildQuiz(QuizPinBox(key: _buildQuizKey), items),
        BuildQuiz(QuizPinBox(), items),
        BuildQuiz(
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
    return ["A", "B", "C", "D", "E", "F", "G"];
  }
}

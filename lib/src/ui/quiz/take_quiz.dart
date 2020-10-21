import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_broccoli/models.dart';

import 'package:smart_broccoli/src/ui/shared/quiz_container.dart';
import 'package:smart_broccoli/src/ui/shared/tabbed_page.dart';

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
  List<Quiz> items;

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
    QuizCollectionModel qcm =
        Provider.of<QuizCollectionModel>(context, listen: true);
    items = qcm.availableQuizzes;

    // Debug code please ignore
    if (items.length == 0) {}
    // Somewhat wasteful to have multiple widgets, but that's how tabs work
    return CustomTabbedPage(
      title: "Take Quiz",
      tabs: [Tab(text: "ALL"), Tab(text: "LIVE"), Tab(text: "SELF-PACED")],
      tabViews: [
        // All quizzes
        QuizContainer(getQuiz(items, null), header: QuizPinBox(key: _buildQuizKey)),

        // Live quiz
        QuizContainer(getQuiz(items, QuizType.LIVE), header: QuizPinBox()),

        /// Self-paced quiz has Text to fill the vertical space
        QuizContainer(
          getQuiz(items, QuizType.SELF_PACED),
          header: ConstrainedBox(
              constraints: BoxConstraints(minHeight: _height ?? 175),
              child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Take a self-paced quiz...\nHave some fun',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ))),
        )
      ],
      hasDrawer: true,
      secondaryBackgroundColour: true,
    );
  }

  List<Quiz> getQuiz(List<Quiz> items, QuizType type) {
    List<Quiz> res = [];
    for (var i = 0; i < items.length; i++) {
      if (items[i].type == type || type == null) {
        res.add(items[i]);
      }
    }
    return res;
  }
}

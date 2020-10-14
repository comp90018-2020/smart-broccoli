import 'package:flutter/material.dart';

import '../shared/tabbed_page.dart';
import 'quiz_container.dart';
import 'quiz_pin_box.dart';

/// Take/manage quiz page
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
        BuildQuiz(QuizPinBox(key: _buildQuizKey), items),

        // Live quiz
        BuildQuiz(QuizPinBox(), items),

        /// Self-paced quiz has Text to fill the vertical space
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
}

/// Background clipper
// class BackgroundClipperMain extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     var path = Path();
//     path.moveTo(0, size.height * 0.63);
//     path.lineTo(0, size.height);
//     path.lineTo(size.width, size.height);
//     path.lineTo(size.width, size.height - size.height * 0.66);
//     return path;
//   }

//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) {
//     return true;
//   }
// }

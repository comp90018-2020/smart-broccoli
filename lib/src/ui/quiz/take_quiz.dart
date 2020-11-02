import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update available quizzes
    Provider.of<QuizCollectionModel>(context, listen: false)
        .refreshAvailableQuizzes();
  }

  @override
  void initState() {
    super.initState();

    // Set _height
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RenderBox renderBox = _buildQuizKey.currentContext.findRenderObject();
      double pinBoxHeight = renderBox.size.height;
      if (pinBoxHeight != _height) {
        setState(() => _height = pinBoxHeight);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomTabbedPage(
      title: "Take Quiz",
      tabs: [Tab(text: "ALL"), Tab(text: "LIVE"), Tab(text: "SELF-PACED")],
      tabViews: [
        // All quizzes
        Consumer<QuizCollectionModel>(builder: (context, collection, child) {
          return QuizContainer(collection.getAvailableQuizzesWhere(),
              header: QuizPinBox(key: _buildQuizKey));
        }),

        // Live quiz
        Consumer<QuizCollectionModel>(
          builder: (context, collection, child) {
            return QuizContainer(
                collection.getAvailableQuizzesWhere(type: QuizType.LIVE),
                header: QuizPinBox());
          },
        ),

        /// Self-paced quiz
        Consumer<QuizCollectionModel>(
          builder: (context, collection, child) {
            return QuizContainer(
              collection.getAvailableQuizzesWhere(type: QuizType.SELF_PACED),
              header: ConstrainedBox(
                  // Has text to fill up vertical space
                  constraints: BoxConstraints(minHeight: _height ?? 175),
                  child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Take a self-paced quiz...\nHave some fun',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ))),
            );
          },
        ),
      ],
      hasDrawer: true,
      secondaryBackgroundColour: true,
    );
  }
}

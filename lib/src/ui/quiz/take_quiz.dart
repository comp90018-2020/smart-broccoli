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

  // See : https://stackoverflow.com/questions/58371874/what-is-diffrence-between-didchangedependencies-and-initstate
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    QuizCollectionModel qcm =
        Provider.of<QuizCollectionModel>(context, listen: true);
    items = qcm.availableQuizzes;
  }

  @override
  Widget build(BuildContext context) {
    // Somewhat wasteful to have multiple widgets, but that's how tabs work
    return Consumer2<QuizCollectionModel, GroupRegistryModel>(
      builder: (context, collection, registry, child) {
        return CustomTabbedPage(
          title: "Take Quiz",
          tabs: [Tab(text: "ALL"), Tab(text: "LIVE"), Tab(text: "SELF-PACED")],
          tabViews: [
            // All quizzes
            QuizContainer(collection.getQuizzesWhere(groupId: null, type: null),
                header: QuizPinBox(key: _buildQuizKey)),

            // Live quiz
            QuizContainer(
                collection.getQuizzesWhere(groupId: null, type: QuizType.LIVE),
                header: QuizPinBox()),

            /// Self-paced quiz has Text to fill the vertical space
            QuizContainer(
              collection.getQuizzesWhere(
                  groupId: null, type: QuizType.SELF_PACED),
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
      },
    );
  }
}

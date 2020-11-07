import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui/shared/indicators.dart';
import 'package:smart_broccoli/src/ui/shared/load_list.dart';
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
        .refreshAvailableQuizzes(refreshIfLoaded: true)
        .catchError((_) => null);
  }

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
    return CustomTabbedPage(
      title: "Take Quiz",
      tabs: [Tab(text: "ALL"), Tab(text: "LIVE"), Tab(text: "SELF-PACED")],
      tabViews: futureTabs(
        errorIndicator: Text("An error has occurred, cannot load"),
        loadingIndicator: LoadingIndicator(EdgeInsets.all(16)),
        future: Provider.of<QuizCollectionModel>(context, listen: false)
            .refreshAvailableQuizzes(),
        headerPadding: const EdgeInsets.fromLTRB(8, 20, 8, 16),
        headers: [
          // All quizzes
          QuizPinBox(key: _buildQuizKey),
          // Live quiz
          QuizPinBox(),
          // Self-paced quiz
          ConstrainedBox(
              // Has text to fill up vertical space
              constraints: BoxConstraints(minHeight: _height ?? 175),
              child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Take a self-paced quiz...\nHave some fun',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ))),
        ],
        children: [
          // All quizzes
          Consumer<QuizCollectionModel>(
            builder: (context, collection, child) {
              return QuizContainer(collection.getAvailableQuizzesWhere());
            },
          ),

          // Live quiz
          Consumer<QuizCollectionModel>(
            builder: (context, collection, child) {
              return QuizContainer(
                collection.getAvailableQuizzesWhere(type: QuizType.LIVE),
              );
            },
          ),

          /// Self-paced quiz
          Consumer<QuizCollectionModel>(
            builder: (context, collection, child) {
              return QuizContainer(
                collection.getAvailableQuizzesWhere(type: QuizType.SELF_PACED),
              );
            },
          ),
        ],
      ),
      hasDrawer: true,
      secondaryBackgroundColour: true,
    );
  }
}

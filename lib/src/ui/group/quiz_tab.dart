import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models.dart';

import 'package:smart_broccoli/src/ui/shared/tabbed_page.dart';
import 'package:smart_broccoli/src/ui/shared/quiz_container.dart';

class QuizTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _QuizTab();
}

class _QuizTab extends State<QuizTab> {
  List<Quiz> items;

  // TODO change this when group logic is implemented
  int groupId = 26;

  @override
  Widget build(BuildContext context) {
    /// Can't be placed in init since we need the context
    /// Further testing is required to see if placing it in login in the best way
    /// forward
    QuizCollectionModel qcm =
    Provider.of<QuizCollectionModel>(context, listen: true);
    items = qcm.availableQuizzes;

    return new Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        child: CustomTabbedPage(
          secondaryBackgroundColour: true,
          title: "YES",
          tabs: [Tab(text: "ALL"), Tab(text: "LIVE"), Tab(text: "SELF-PACED")],
          tabViews: [
            QuizContainer(getQuiz(items, null), hiddenButton: true),
            QuizContainer(getQuiz(items, QuizType.LIVE), hiddenButton: true),
            QuizContainer(getQuiz(items, QuizType.SELF_PACED),
                hiddenButton: true),
          ],
          hasDrawer: false,
          primary: false,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {},
            label: Text('CREATE QUIZ'),
            icon: Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  List<Quiz> getQuiz(List<Quiz> items, QuizType type) {
    List<Quiz> res = [];
    for (var i = 0; i < items.length; i++) {
      if (items[i].groupId == groupId &&
          (items[i].type == type || type == null)) {
        res.add(items[i]);
      }
    }
    return res;
  }
}

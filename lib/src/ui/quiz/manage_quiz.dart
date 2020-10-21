import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_broccoli/src/data/group.dart';
import 'package:smart_broccoli/src/data/quiz.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui/shared/quiz_container.dart';
import 'package:smart_broccoli/src/ui/shared/tabbed_page.dart';
import 'package:smart_broccoli/theme.dart';

/// Manage quiz page
class ManageQuiz extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _ManageQuizState();
}

/// Get Quiz, we are assuming that the quizzes displayed here are quizzes where
/// The user is the owner of
class _ManageQuizState extends State<ManageQuiz> {
  // TODO: replace with provider inside build
  List<Quiz> items;
  List<Group> group;
  int gid;

  @override
  Widget build(BuildContext context) {
    // Provider Init code
    QuizCollectionModel qcm =
        Provider.of<QuizCollectionModel>(context, listen: true);
    GroupRegistryModel grm =
        Provider.of<GroupRegistryModel>(context, listen: true);
    group = grm.createdGroups;
    items = qcm.createdQuizzes;

    // Somewhat wasteful to have multiple widgets, but that's how tabs work
    return CustomTabbedPage(
      title: "Manage Quiz",
      tabs: [Tab(text: "ALL"), Tab(text: "LIVE"), Tab(text: "SELF-PACED")],
      tabViews: [
        // All quizzes
        QuizContainer(getQuiz(null),
            header: _groupSelector(), hiddenButton: true),

        // Live quiz
        QuizContainer(getQuiz(QuizType.LIVE),
            header: _groupSelector(), hiddenButton: true),

        /// Self-paced quiz
        QuizContainer(getQuiz(QuizType.SELF_PACED),
            header: _groupSelector(), hiddenButton: true),
      ],
      hasDrawer: true,
      secondaryBackgroundColour: true,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: Text('CREATE QUIZ'),
        icon: Icon(Icons.add),
      ),
    );
  }

  /// Quiz selection dropdown
  Widget _groupSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      constraints: BoxConstraints(maxWidth: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('GROUP',
              style: TextStyle(
                  color: SmartBroccoliColourScheme().onBackground,
                  fontSize: 16)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: DropdownButton(
                  underline: Container(),
                  onChanged: (_) {},
                  isExpanded: true,
                  items: buildDropDownMenu(),
                  /*
                    DropdownMenuItem(
                        child: Center(child: Text('A')),
                        value: 0,
                        onTap: () => updateList()),
                    DropdownMenuItem(
                        child: Center(child: Text('B')),
                        value: 1,
                        onTap: () => updateList())
                    */
                  value: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem> buildDropDownMenu() {
    List<DropdownMenuItem> res = [];
    // note that GID != i where i is the iteration index
    for (var i = 0; i < group.length; i++) {
      res.add(DropdownMenuItem(
          child: Center(
            child: Text("Testing"),
          ),
          value: i,
          onTap: () => updateList(i)));
    }
    return res;
  }

  void updateList(int i) {
    setState(() {
      gid = group[i].id;
    });
  }

  List<Quiz> getQuiz(QuizType type) {
    List<Quiz> res = [];
    for (var j = 0; j < items.length; j++) {
      if ((items[j].type == type || type == null) &&
          items[j].groupId == gid &&
          items[j].role == GroupRole.OWNER) {
        res.add(items[j]);
      }
    }
    return res;
  }
}

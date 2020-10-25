import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_broccoli/src/data.dart';
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
  int gid = 0;

  @override
  Widget build(BuildContext context) {
    // Somewhat wasteful to have multiple widgets, but that's how tabs work
    return Consumer2<QuizCollectionModel, GroupRegistryModel>(
      builder: (context, collection, registry, child) {
        group = registry.createdGroups;
        return CustomTabbedPage(
          title: "Manage Quiz",
          tabs: [Tab(text: "ALL"), Tab(text: "LIVE"), Tab(text: "SELF-PACED")],
          tabViews: [
            // All quizzes
            QuizContainer(
                (group.length != 0)
                    ? collection.getQuizzesWhere(
                        groupId: group[gid].id, type: null)
                    : [],
                header: _groupSelector(),
                hiddenButton: true),

            // Live quiz
            QuizContainer(
                (group.length != 0)
                    ? collection.getQuizzesWhere(
                        groupId: group[gid].id, type: QuizType.LIVE)
                    : [],
                header: _groupSelector(),
                hiddenButton: true),

            /// Self-paced quiz
            QuizContainer(
                (group.length != 0)
                    ? collection.getQuizzesWhere(
                        groupId: group[gid].id, type: QuizType.SELF_PACED)
                    : [],
                header: _groupSelector(),
                hiddenButton: true),
          ],
          hasDrawer: true,
          secondaryBackgroundColour: true,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              _createQuiz();
            },
            label: Text('CREATE QUIZ'),
            icon: Icon(Icons.add),
          ),
        );
      },
    );
  }

  /// Route to create quiz here
  /// Define group affiliation with the gid varible
  void _createQuiz() {}

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
                  value: gid,
                  underline: Container(),
                  onChanged: (_) {},
                  isExpanded: true,
                  items: buildDropDownMenu(),
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

    /// Defensive programming to avoid an error in an event of there being no
    /// groups
    if (group.length == 0) {
      res.add(DropdownMenuItem(
          child: Center(
            child: Text(" "),
          ),
          value: 0,
          onTap: () => {}));
    } else {
      // note that GID != i where i is the iteration index
      for (var i = 0; i < group.length; i++) {
        res.add(DropdownMenuItem(
            child: Center(
              child: Text(group[i].name),
            ),
            value: i,
            onTap: () => updateList(i)));
      }
    }
    return res;
  }

  void updateList(int i) {
    setState(() {
      gid = i;
    });
  }
}

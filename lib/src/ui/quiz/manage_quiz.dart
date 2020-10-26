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
  int gid = 0;

  @override
  Widget build(BuildContext context) {
    // Somewhat wasteful to have multiple widgets, but that's how tabs work
    return Consumer2<QuizCollectionModel, GroupRegistryModel>(
      builder: (context, collection, registry, child) {
        return CustomTabbedPage(
          title: "Manage Quiz",
          tabs: [Tab(text: "ALL"), Tab(text: "LIVE"), Tab(text: "SELF-PACED")],
          tabViews: [
            // All quizzes
            QuizContainer(
                (registry.createdGroups != 0)
                    ? collection.getQuizzesWhere(
                        groupId: registry.createdGroups[gid].id)
                    : [],
                header: _groupSelector(registry.createdGroups),
                hiddenButton: true),

            // Live quiz
            QuizContainer(
                (registry.createdGroups.length != 0)
                    ? collection.getQuizzesWhere(
                        groupId: registry.createdGroups[gid].id,
                        type: QuizType.LIVE)
                    : [],
                header: _groupSelector(registry.createdGroups),
                hiddenButton: true),

            /// Self-paced quiz
            QuizContainer(
                (registry.createdGroups != 0)
                    ? collection.getQuizzesWhere(
                        groupId: registry.createdGroups[gid].id,
                        type: QuizType.SELF_PACED)
                    : [],
                header: _groupSelector(registry.createdGroups),
                hiddenButton: true),
          ],
          hasDrawer: true,
          secondaryBackgroundColour: true,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {},
            label: Text('CREATE QUIZ'),
            icon: Icon(Icons.add),
          ),
        );
      },
    );
  }

  /// Quiz selection dropdown
  Widget _groupSelector(List<Group> group) {
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
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                    value: gid,
                    underline: Container(),
                    onChanged: (i) {
                      updateList(i);
                    },
                    isExpanded: true,
                    items: buildDropDownMenu(group),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem> buildDropDownMenu(List<Group> group) {
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
        res.add(
          DropdownMenuItem(
            child: Center(
              child: Text(group[i].name),
            ),
            value: i,
          ),
        );
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

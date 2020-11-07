import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui/shared/group_dropdown.dart';
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
  // The group that is selected
  int _groupId;

  // See : https://stackoverflow.com/questions/58371874
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update created quizzes
    Provider.of<QuizCollectionModel>(context, listen: false)
        .refreshCreatedQuizzes(refreshIfLoaded: true)
        .catchError((_) => null);
    // Ensure that group list is up to date
    Provider.of<GroupRegistryModel>(context, listen: false)
        .getCreatedGroups(refreshIfLoaded: true)
        .catchError((_) => null);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizCollectionModel>(
      builder: (context, collection, child) {
        return FutureBuilder(
          future: Provider.of<QuizCollectionModel>(context, listen: false)
              .refreshCreatedQuizzes(),
          builder: (context, snapshot) {
            log("Manage quiz future ${snapshot.toString()}");

            return CustomTabbedPage(
              title: "Manage Quiz",
              tabs: [
                Tab(text: "ALL"),
                Tab(text: "LIVE"),
                Tab(text: "SELF-PACED")
              ],
              tabViews: [
                Consumer<QuizCollectionModel>(
                    builder: (context, collection, child) {
                  // All quizzes
                  return QuizContainer(
                      snapshot.hasData
                          ? collection.getCreatedQuizzesWhere(groupId: _groupId)
                          : null,
                      error: snapshot.hasError
                          ? Center(child: Text("Cannot load quizzes"))
                          : null,
                      header: _groupSelector(),
                      hiddenButton: true);
                }),
                Consumer<QuizCollectionModel>(
                    builder: (context, collection, child) {
                  // Live quiz
                  return QuizContainer(
                      snapshot.hasData
                          ? collection.getCreatedQuizzesWhere(
                              groupId: _groupId, type: QuizType.LIVE)
                          : null,
                      error: snapshot.hasError
                          ? Center(child: Text("Cannot load quizzes"))
                          : null,
                      header: _groupSelector(),
                      hiddenButton: true);
                }),
                Consumer<QuizCollectionModel>(
                    builder: (context, collection, child) {
                  /// Self-paced quiz
                  return QuizContainer(
                      snapshot.hasData
                          ? collection.getCreatedQuizzesWhere(
                              groupId: _groupId, type: QuizType.SELF_PACED)
                          : null,
                      header: _groupSelector(),
                      hiddenButton: true);
                }),
              ],
              hasDrawer: true,
              secondaryBackgroundColour: true,
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () {
                  if (_groupId == null) {
                    Navigator.of(context).pushNamed('/quiz/');
                  } else {
                    Navigator.of(context).pushNamed('/group/$_groupId/quiz');
                  }
                },
                label: Text('CREATE QUIZ'),
                icon: Icon(Icons.add),
              ),
            );
          },
        );
      },
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
                child: DropdownButtonHideUnderline(
                  child: Consumer<GroupRegistryModel>(
                    builder: (context, collection, child) {
                      return GroupDropdown(
                        collection.createdGroups,
                        _groupId,
                        centered: true,
                        defaultText: "All Groups",
                        onChanged: (i) {
                          setState(() {
                            _groupId = i;
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

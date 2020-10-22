import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui/shared/tabbed_page.dart';
import 'package:smart_broccoli/src/ui/shared/quiz_container.dart';

class QuizTab extends StatelessWidget {
  final int groupId;

  QuizTab(this.groupId);

  @override
  Widget build(BuildContext context) {
    Provider.of<QuizCollectionModel>(context).refreshAvailableQuizzes();
    Provider.of<QuizCollectionModel>(context).refreshCreatedQuizzes();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        child: Consumer2<GroupRegistryModel, QuizCollectionModel>(
            builder: (context, registry, collection, child) {
          final Group group = registry.getGroup(groupId);

          return group == null
              ? Container()
              : CustomTabbedPage(
                  secondaryBackgroundColour: true,
                  title: "YES",
                  tabs: [
                    Tab(text: "ALL"),
                    Tab(text: "LIVE"),
                    Tab(text: "SELF-PACED")
                  ],
                  tabViews: [
                    // all quizzes
                    QuizContainer(
                      (group.role == GroupRole.OWNER
                              ? collection.createdQuizzes
                              : collection.availableQuizzes)
                          .where((Quiz quiz) => quiz.groupId == group.id)
                          .toList(),
                      hiddenButton: true,
                    ),

                    // live quizzes
                    QuizContainer(
                      (group.role == GroupRole.OWNER
                              ? collection.createdQuizzes
                              : collection.availableQuizzes)
                          .where((Quiz quiz) =>
                              quiz.groupId == group.id &&
                              quiz.type == QuizType.LIVE)
                          .toList(),
                      hiddenButton: true,
                    ),

                    // self-paced quizzes
                    QuizContainer(
                      (group.role == GroupRole.OWNER
                              ? collection.createdQuizzes
                              : collection.availableQuizzes)
                          .where((Quiz quiz) =>
                              quiz.groupId == group.id &&
                              quiz.type == QuizType.SELF_PACED)
                          .toList(),
                      hiddenButton: true,
                    ),
                  ],
                  hasDrawer: false,
                  primary: false,
                  floatingActionButton: FloatingActionButton.extended(
                    onPressed: () {},
                    label: Text('CREATE QUIZ'),
                    icon: Icon(Icons.add),
                  ),
                );
        }),
      ),
    );
  }
}

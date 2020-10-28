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
                      collection.getQuizzesWhere(groupId: group.id),
                      hiddenButton: true,
                    ),

                    // live quizzes
                    QuizContainer(
                      collection.getQuizzesWhere(
                          groupId: group.id, type: QuizType.LIVE),
                      hiddenButton: true,
                    ),

                    // self-paced quizzes
                    QuizContainer(
                      collection.getQuizzesWhere(
                          groupId: group.id, type: QuizType.SELF_PACED),
                      hiddenButton: true,
                    ),
                  ],
                  hasDrawer: false,
                  primary: false,
                  floatingActionButton: group.role == GroupRole.OWNER
                      ? FloatingActionButton.extended(
                          onPressed: () =>
                              Navigator.of(context).pushNamed('/quiz'),
                          label: Text('CREATE QUIZ'),
                          icon: Icon(Icons.add),
                        )
                      : null,
                );
        }),
      ),
    );
  }
}

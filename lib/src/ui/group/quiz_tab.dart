import 'dart:developer';
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
          return FutureBuilder(
              future: registry.getGroupQuizzes(groupId),
              builder: (context, snapshot) {
                log("Quiz tab future ${snapshot.toString()}");
                // To get into the members tab, the group must be loaded
                var group = registry.getGroupFromCache(groupId);

                return CustomTabbedPage(
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
                      snapshot.hasData
                          ? collection.getQuizzesWhere(groupId: group.id)
                          : null,
                      error: snapshot.hasError
                          ? Center(child: Text("Cannot load quizzes"))
                          : null,
                      noQuizPlaceholder: "There aren't any active quizzes",
                      hiddenButton: true,
                      padding: EdgeInsets.symmetric(vertical: 24),
                    ),

                    // live quizzes
                    QuizContainer(
                      snapshot.hasData
                          ? collection.getQuizzesWhere(
                              groupId: group.id, type: QuizType.LIVE)
                          : null,
                      error: snapshot.hasError
                          ? Center(child: Text("Cannot load quizzes"))
                          : null,
                      noQuizPlaceholder: "There aren't any active quizzes",
                      hiddenButton: true,
                      padding: EdgeInsets.symmetric(vertical: 24),
                    ),

                    // self-paced quizzes
                    QuizContainer(
                      snapshot.hasData
                          ? collection.getQuizzesWhere(
                              groupId: group.id, type: QuizType.SELF_PACED)
                          : null,
                      error: snapshot.hasError
                          ? Center(child: Text("Cannot load quizzes"))
                          : null,
                      noQuizPlaceholder: "There aren't any active quizzes",
                      hiddenButton: true,
                      padding: EdgeInsets.symmetric(vertical: 24),
                    ),
                  ],
                  hasDrawer: false,
                  primary: false,
                  floatingActionButton: group.role == GroupRole.OWNER
                      ? FloatingActionButton.extended(
                          onPressed: () => Navigator.of(context)
                              .pushNamed('/group/$groupId/quiz'),
                          label: Text('CREATE QUIZ'),
                          icon: Icon(Icons.add),
                        )
                      : null,
                );
              });
        }),
      ),
    );
  }
}

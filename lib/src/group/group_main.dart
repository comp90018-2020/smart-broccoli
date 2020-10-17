import 'package:flutter/material.dart';
import 'package:smart_broccoli/src/group/members_tab.dart';
import 'package:smart_broccoli/src/group/quiz_tab.dart';

class GroupMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(child: Text("Quiz")),
              Tab(child: Text("Members")),
            ],
          ),
          title: Text('COMP1234'),
        ),
        body: TabBarView(
          children: [
            QuizTab(),
            MembersTab(),
          ],
        ),
      ),
    );
  }
}

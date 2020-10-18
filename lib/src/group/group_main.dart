import 'package:flutter/material.dart';
import 'package:smart_broccoli/src/group/quiz_tab.dart';

class GroupMain extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _GroupMain();
}

class _GroupMain extends State<GroupMain> with TickerProviderStateMixin {
  bool showMore = true;

  final List<Tab> myTabs = <Tab>[
    Tab(child: Text("Quiz")),
    Tab(child: Text("Members")),
  ];

  TabController _controller;

  void initState() {
    super.initState();
    _controller = new TabController(length: 2, vsync: this);
    _controller.addListener(_handleSelected);
  }

  void _handleSelected() {
    setState(() {
      if (_controller.index == 1) {
        showMore = false;
      } else {
        showMore = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: new TabBar(
          controller: _controller,
          labelColor: Colors.white,
          indicator: UnderlineTabIndicator(),
          tabs: myTabs,
        ),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {},
        ),
        actions: showMore
            ? [
                IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () {},
                )
              ]
            : [
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {},
                )
              ],
        centerTitle: true,
        title: Text('COMP1234'),
      ),
      body: TabBarView(
        controller: _controller,
        children: [
          moveToQuizTab(),
          moveToMembersTab(),
        ],
      ),
    );
  }

  Widget moveToQuizTab() {
    return QuizTab();
  }

  Widget moveToMembersTab() {
    return QuizTab();
  }
}

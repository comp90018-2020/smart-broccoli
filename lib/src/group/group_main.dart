import 'package:flutter/material.dart';
import './members_tab.dart';
import './quiz_tab.dart';

class GroupMain extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _GroupMain();
}

class _GroupMain extends State<GroupMain> with TickerProviderStateMixin {
  // Main tab controller
  TabController _controller;

  void initState() {
    super.initState();
    _controller = new TabController(length: 2, vsync: this);
    _controller.addListener(_handleSelected);
  }

  // On the first tab?
  bool _onQuizPage = true;

  // Tab controller change
  void _handleSelected() {
    setState(() {
      _onQuizPage = _controller.index == 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,

      appBar: AppBar(
        bottom: new TabBar(
          controller: _controller,
          labelColor: Colors.white,
          indicator: UnderlineTabIndicator(),
          tabs: [
            Tab(child: Text("Quiz")),
            Tab(child: Text("Members")),
          ],
        ),

        // Close button
        leading: new IconButton(
          icon: new Icon(Icons.close),
          enableFeedback: false,
          splashRadius: 20,
          onPressed: () => Navigator.of(context).pop(),
        ),

        // More actions
        actions: _onQuizPage
            ? []
            : [
                IconButton(
                  icon: Icon(Icons.more_vert),
                  padding: EdgeInsets.zero,
                  splashRadius: 20,
                  onPressed: () {},
                )
              ],

        centerTitle: true,
        title: Text('COMP1234'),
      ),

      // Tabs
      body: TabBarView(
        controller: _controller,
        children: [
          QuizTab(),
          MembersTab(),
        ],
      ),
    );
  }
}

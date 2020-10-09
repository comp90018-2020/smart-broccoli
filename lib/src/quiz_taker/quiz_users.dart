import 'dart:async';

import 'package:flutter/material.dart';

class QuizUsers extends StatefulWidget {
  QuizUsers({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _QuizUsers();
}

class _QuizUsers extends State<QuizUsers> {
  // Placeholder list, the list contents should be replaced with usernames.
  List<String> propList;

  // Initiate timers on start up
  @override
  void initState() {
    super.initState();
    propList = getUserList();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        // height: 500.0,
        child: ListView.separated(
          itemCount: propList.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              height: 50,
              child: Center(child: Text(propList[index])),
            );
          },
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
        ),
      ),
    );
  }

  // Please put server communication code here

  List<String> getUserList() {
    return ["HELLO", "HELLO2", "HELLO3", "HELLO4", "HELLO5"];
  }

  // I suggest a timer which get's the user list every n seconds
  // And the list get's updated accordingly
  void updateList() {
    setState(
      () {
        propList.add("NEW PERSON");
      },
    );
  }
}

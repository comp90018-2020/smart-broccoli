import 'package:flutter/material.dart';

import 'package:smart_broccoli/theme.dart';

class MembersTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _MembersTab();
}

class _MembersTab extends State<MembersTab> {
  List<String> _users;

  // Initiate timers on start up
  @override
  void initState() {
    super.initState();
    _users = getUserList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SmartBroccoliColourScheme.membersTabBackground,
      padding: EdgeInsets.symmetric(vertical: 12),
      child: ListView.separated(
        itemCount: _users.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
              dense: true,
              // Avatar
              leading: UserAvatar(),
              // Name
              title: Text(
                _users[index],
              ),
              // Remove
              trailing: IconButton(
                icon: Icon(
                  Icons.person_remove,
                ),
                splashRadius: 20,
                onPressed: () {},
              ));
        },
        separatorBuilder: (BuildContext context, int index) =>
            const Divider(color: Colors.transparent),
      ),
    );
  }

  List<String> getUserList() {
    return ["HELLO", "HELLO2", "HELLO3", "HELLO4", "HELLO5"];
  }

  // I suggest a timer which get's the user list every n seconds
  // And the list get's updated accordingly
  void updateList() {
    setState(
      () {
        _users.add("NEW PERSON");
      },
    );
  }
}

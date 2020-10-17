import 'package:flutter/material.dart';
import 'package:smart_broccoli/theme.dart';

class MembersTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _MembersTab();
}

class _MembersTab extends State<MembersTab> {
  List<String> propList;

  // Initiate timers on start up
  @override
  void initState() {
    super.initState();
    propList = getUserList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        groupBackground(true),
        Expanded(
          child: Container(
            // height: 500.0,
            child: ListView.separated(
              itemCount: propList.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                    // TODO inject profile pic to User Avartar
                    leading: UserAvatar(),
                    title: Text(propList[index],style: TextStyle(color: Colors.white), ),
                    trailing: IconButton(
                      icon: Icon(Icons.person_add,color: Colors.white,),
                      onPressed: addFriend(),
                    ));
              },
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(),
            ),
          ),
        ),
      ],
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
        propList.add("NEW PERSON");
      },
    );
  }

  addFriend() {
    print("TODO");
  }
}

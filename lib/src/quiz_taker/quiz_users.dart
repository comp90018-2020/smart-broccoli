import 'package:flutter/material.dart';

class QuizUsers extends StatelessWidget {
  // Hold list of users
  // TODO: change to correct model, provider picture
  final List<String> userList;

  QuizUsers(this.userList);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: userList.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
          child: Row(children: [
            // Profile image
            Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(100))),
            // Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(userList[index]),
            )
          ]),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }
}

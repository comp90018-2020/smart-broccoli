import 'package:flutter/material.dart';
import 'package:smart_broccoli/src/quiz/widgets/user.dart';

/// Hold list of users
class QuizUsers extends StatelessWidget {
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
          padding: index == 0 || index == userList.length - 1
              ? EdgeInsets.only(
                  left: 25,
                  right: 25,
                  top: index == 0 ? 15 : 5,
                  bottom: index == 0 ? 5 : 15,
                )
              : const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
          child: UserItem(userList[index]),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }
}

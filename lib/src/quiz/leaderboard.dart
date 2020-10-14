import 'package:flutter/material.dart';
import 'package:smart_broccoli/src/quiz/widgets/user.dart';

import 'package:smart_broccoli/theme.dart';
import '../shared/page.dart';

/// Leaderboard page
class QuizLeaderboard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LeaderBoardLobby();
}

class _LeaderBoardLobby extends State<QuizLeaderboard> {
  // Entry function
  @override
  Widget build(BuildContext context) {
    return new CustomPage(
      title: "Leaderboard",
      background: [
        Container(
          child: ClipPath(
            clipper: _BackgroundRectClipper(),
            child: Container(
              color: Color(0xFFFEC12D),
            ),
          ),
        ),
        Container(
          child: ClipPath(
            clipper: _BackgroundClipper(),
            child: Container(
              color: Theme.of(context).colorScheme.background,
            ),
          ),
        ),
      ],
      child: Column(
        children: <Widget>[
          // Top 3
          Container(
              padding: EdgeInsets.all(16),
              constraints: BoxConstraints(maxHeight: 165),
              child: Wrap(
                alignment: WrapAlignment.center,
                runAlignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 25,
                children: <Widget>[
                  _topThreeUsers(
                    "Winner 2",
                    50,
                    Text(
                      '2',
                      style: SmartBroccoliTheme.leaderboardRankStyle,
                    ),
                  ),
                  _topThreeUsers("Winner 1", 75,
                      Text('1', style: SmartBroccoliTheme.leaderboardRankStyle),
                      bolded: true),
                  _topThreeUsers(
                      "Winner 3",
                      50,
                      Text('3',
                          style: SmartBroccoliTheme.leaderboardRankStyle)),
                ],
              )),

          // Current user & ranking
          Container(
              margin: EdgeInsets.only(top: 12, bottom: 3),
              height: 25.0 + 35,
              child: _leaderboardList(["A"])),

          // List of users
          Expanded(child: _leaderboardList(["A", "B", "C"])),
        ],
      ),
    );
  }

  // Creates user image and name
  Widget _topThreeUsers(text, double dimensions, Widget inner,
      {bool bolded = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // Bubble
        Container(
            height: dimensions,
            width: dimensions,
            decoration: WinnerBubble(),
            child: Align(alignment: Alignment.center, child: inner)),
        // Name
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            text,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontWeight: bolded ? FontWeight.bold : FontWeight.normal),
          ),
        ),
      ],
    );
  }

  Widget _leaderboardList(List<String> list) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: list.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 3),
          child: Row(children: [
            Text(
              '1',
              style: SmartBroccoliTheme.listItemTextStyle,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: UserItem('name'),
              ),
            ),
            Wrap(
                spacing: 5,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('3,500', style: SmartBroccoliTheme.listItemTextStyle),
                  Icon(Icons.star, color: Color(0xFF656565))
                ])
          ]),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }
}

// Curved clipper
class _BackgroundClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    path.lineTo(0, 125);
    var firstControlPoint = new Offset(size.width / 4, 160);
    var firstEndPoint = new Offset(size.width / 2, 145);
    var secondControlPoint = new Offset(size.width - (size.width / 4), 125);
    var secondEndPoint = new Offset(size.width, 150);

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height / 3);
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

// User highlight clipper
class _BackgroundRectClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(15, 0);
    path.lineTo(15, 165.0 + 40);
    path.lineTo(size.width - 15, 165.0 + 40);
    path.lineTo(size.width - 15, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

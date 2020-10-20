import 'package:flutter/material.dart';
import 'package:smart_broccoli/theme.dart';
import 'package:smart_broccoli/src/ui/shared/page.dart';

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
        // The clip for the current user's rank
        Container(
          child: ClipPath(
            clipper: _BackgroundRectClipper(),
            child: Container(
              color: Color(0xFFFEC12D),
            ),
          ),
        ),
        // Overall wavy clip
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
              margin: EdgeInsets.symmetric(vertical: 8),
              // Lowest point of green area to end of yellow (150 -> 205)
              // See below for more details
              height: 65,
              child: _leaderboardList(["A"], scrollable: false)),

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

  Widget _leaderboardList(List<String> list, {bool scrollable = true}) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: list.length,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      physics: scrollable ? null : NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Rank
              Text(
                '1',
                style: SmartBroccoliTheme.listItemTextStyle,
              ),
              // Name/image
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
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
                    child: Text('name',
                        style: SmartBroccoliTheme.listItemTextStyle),
                  )
                ]),
              )
            ],
          ),
          // Score
          trailing: Wrap(
              spacing: 5,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('3,500', style: SmartBroccoliTheme.listItemTextStyle),
                Icon(Icons.star, color: Color(0xFF656565))
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
    // Init width = 0, height = 0
    // GOTO width = 15 height = 0
    path.lineTo(15, 0);
    // GOTO width 15, height 165.0 + 30
    path.lineTo(15, 165.0 + 40);
    // Make a curve at control point width = 15, height = 165+30
    // i.e the Bottom leftmost point
    // Starting at width 15, height 165.0 + 30
    // And ending at width 20, 165.0+40
    path.quadraticBezierTo(15, 165.0 + 50, 25, 165.0 + 50);
    // From width 20, 165.0+40 goto Width = Width max - 20 height = 165.0+40
    path.lineTo(size.width - 25, 165.0 + 50);
    // Make a curve at control point width max - 15, height = 165+40
    // i.e the Bottom right most point
    // Starting at size.width - 20 , 165.0 + 40
    // And ending at  size.width - 15, 165.0 + 30
    path.quadraticBezierTo(
        size.width - 15, 165.0 + 50, size.width - 15, 165.0 + 40);
    // Finish up at the right top side
    path.lineTo(size.width - 15, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

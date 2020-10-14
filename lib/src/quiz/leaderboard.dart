import 'package:flutter/material.dart';

import 'package:smart_broccoli/theme.dart';
import '../shared/page.dart';
import 'question.dart';
import 'quiz.dart';
import 'widgets/users.dart';

/// Leaderboard page
class LeaderBoardLobby extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LeaderBoardLobby();
}

class _LeaderBoardLobby extends State<LeaderBoardLobby> {
  // Entry function
  @override
  Widget build(BuildContext context) {
    return new CustomPage(
      title: "Leaderboard",
      background: Container(
        child: ClipPath(
          clipper: _BackgroundClipper(),
          child: Container(
            color: Theme.of(context).colorScheme.background,
          ),
        ),
      ),
      child: Stack(
        children: <Widget>[
          // The player status
          _playerStats(),

          // Then the rest overlayed on top
          Container(
            child: new Column(
              children: <Widget>[
                SizedBox(height: 20),
                _topLeaderBoard(),
                SizedBox(height: 100),
                // The list of Quiz players
                //_quizPlayers(),
                QuizUsers(["A", "B", "C"]),
                // Debug nav bar please remove
                _bottomNavBar()
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _playerStats() {
    return new Positioned(
      // TODO I need to find a way to fix this relative to everything else
      bottom: 450,
      left: 15,
      width: 360,
      height: 300,

      // alignment: Alignment.lerp(Alignment.topCenter, Alignment.center, ),
      child: PlayerStatsCard("Name and other data here"),
    );
  }

  Widget _bottomNavBar() {
    return new BottomAppBar(
      child: Row(
        children: [
          Row(
            children: <Widget>[
              IconButton(
                  icon: Icon(Icons.clear), onPressed: () => _onItemTapped(0)),
              Text("Leave Quiz")
            ],
          ),
          Spacer(),
          Row(
            children: <Widget>[
              Text("Next Question"),
              IconButton(
                  icon: Icon(Icons.navigate_next),
                  onPressed: () => _onItemTapped(1)),
              // Text("Next Question")
            ],
          ),
          //IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
    );
  }

  Widget topThreeUsers(double h, double w, text) {
    return Column(
      children: <Widget>[
        Container(
            height: h,
            width: w,
            //TODO put picture stuff here
            decoration: BoxDecoration1()),
        Text(text),
      ],
    );
  }

  Widget _topLeaderBoard() {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        topThreeUsers(50, 50, "Winner 1"),
        SizedBox(width: 50),
        topThreeUsers(100, 100, "Winner 2"),
        SizedBox(width: 50),
        topThreeUsers(50, 50, "Winner 3"),
      ],
    );
  }

  void _onItemTapped(int value) {
    if (value == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => QuizQuestion()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TakeQuiz()),
      );
    }
  }
}

/// Used to design the background
class _BackgroundClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    path.lineTo(0, size.height / 4.25);
    var firstControlPoint = new Offset(size.width / 4, size.height / 3.5);
    var firstEndPoint = new Offset(size.width / 2, size.height / 3 - 60);
    var secondControlPoint =
        new Offset(size.width - (size.width / 4), size.height / 3.5 - 65);
    var secondEndPoint = new Offset(size.width, size.height / 3.5 - 40);

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

import 'package:flutter/material.dart';

import 'package:smart_broccoli/theme.dart';
import '../shared/page.dart';
import 'question.dart';
import 'quiz.dart';
import 'widgets/users.dart';

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
              color: Colors.yellow,
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
                spacing: 10,
                children: <Widget>[
                  topThreeUsers(50, 50, "Winner 1"),
                  topThreeUsers(100, 100, "Winner 2"),
                  topThreeUsers(50, 50, "Winner 3"),
                ],
              )),

          // List of users
          QuizUsers(["A", "B", "C"]),

          // Temporary nav bar
          _bottomNavBar(),
        ],
      ),
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(height: h, width: w, decoration: BoxDecoration1()),
        Text(text),
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

    path.lineTo(0, 125);
    var firstControlPoint = new Offset(size.width / 4, 165);
    var firstEndPoint = new Offset(size.width / 2, 150);
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

// Used to clip the background
class _BackgroundRectClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, 165.0 + 30);
    path.lineTo(size.width, 165.0 + 30);
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

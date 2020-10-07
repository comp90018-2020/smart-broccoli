import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:smart_broccoli/src/quiz_taker/quiz_question.dart';
import 'package:smart_broccoli/src/quiz_taker/quiz_taker.dart';
import 'package:smart_broccoli/theme.dart';

/// The Skeleton for the Leaderboard lobby
/// Unfinished as it is beyond my skill ability
/// There are pending changes
class LeaderBoardLobby extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LeaderBoardLobby();
}

// Used to design the background
// Looks like a hack, but apparently this isn't a hack according to docs
class BackgroundClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    // path.moveTo(0, size.height * 0.66);
    //  path.moveTo(0, size.width*1.5);
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

class _LeaderBoardLobby extends State<LeaderBoardLobby> {
  int _selectedIndex = 0;

  // Placeholder list, the list contents should be replaced with usernames.
  List<String> propList = ["HELLO", "BOB", "MICROOSFT", "OOOOOF"];
  int val = 0;

  // Entry function
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onBackground,
      appBar: AppBar(
        title: Text("Quiz"),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
      ),
      // Stacks are used to stack widgets
      // Since the background is now a widget, it comes first
      body: Stack(
        children: <Widget>[
          // The player status
          _playerStats(),
          // Background shapes (The green part)
          _backgroundShapes(),
          // Then the rest overlayed on top
          Container(
            child: new Column(
              children: <Widget>[
                SizedBox(height: 20),
                _topLeaderBoard(),
                SizedBox(height: 100),
                // The list of Quiz players
                _quizPlayers(),
                // Debug nav bar please remove
                _bottomNavBar()
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _backgroundShapes(){
    return new Container(
      child: ClipPath(
        clipper: BackgroundClipper(),
        child: Container(
          color: Theme.of(context).colorScheme.background,
        ),
      ),
    );
    // Then the rest
  }

  Widget _playerStats(){
    return new Positioned(
      // TODO fine tune this to align with centre
      bottom: 450,
      left: 15,
      width: 360,
      height: 300,

      // alignment: Alignment.lerp(Alignment.topCenter, Alignment.center, ),
      child: playerStatsCard("Name and other data here"),
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

    Widget topThreeUsers(double  h, double w,text){
      return Column(
        children: <Widget>[
          Container(
              height: h,
              width: w,
              //TODO put picture stuff here
              // child: Icon(Icons.)
              decoration: BoxDecoration1()),
          Text(text),
        ],
      );
    }


  Widget _topLeaderBoard() {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      //Center Column contents vertically,
      crossAxisAlignment: CrossAxisAlignment.center,
      //Center Column contents horizontally,
      children: <Widget>[
        topThreeUsers(50,50,"Winner 1"),
        SizedBox(width: 50),
        topThreeUsers(100,100,"Winner 2"),
        SizedBox(width: 50),
        topThreeUsers(50,50,"Winner 3"),
      ],
    );
  }

  // Quiz players, the list of quiz users in the current lobby
  Widget _quizPlayers() {
    return Expanded(
      child: Container(
        height: 500.0,
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

  void _onItemTapped(int value) {
    if (value == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => QuizQuestion()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => QuizTaker()),
      );
    }
  }
}

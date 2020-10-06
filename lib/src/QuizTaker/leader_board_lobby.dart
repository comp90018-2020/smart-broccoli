import 'dart:async';

import 'package:flutter/material.dart';

/// The Skeleton for the Leaderboard lobby
/// Unfinished as it is beyond my skill ability
/// There are pending changes
class leaderBoardLobby extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _leaderBoardLobby();
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
    var firstControlPoint = new Offset(size.width / 4, size.height / 3);
    var firstEndPoint = new Offset(size.width / 2, size.height / 3 - 60);
    var secondControlPoint =
    new Offset(size.width - (size.width / 4), size.height / 3.5 - 65);
    var secondEndPoint = new Offset(size.width, size.height / 3 - 40);

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

class _leaderBoardLobby extends State<leaderBoardLobby> {


  // Placeholder list, the list contents should be replaced with usernames.
  List<String> propList = ["HELLO", "BOB", "MICROOSFT", "OOOOOF"];
  int val = 0;


  // Entry function
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Theme
          .of(context)
          .colorScheme
          .onBackground,
      appBar: AppBar(
        title: Text("Quiz"),
        centerTitle: true,
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .background,
        elevation: 0,
      ),
      // Stacks are used to stack widgets
      // Since the background is now a widget, it comes first
      body: Stack(
        children: <Widget>[
          Container(
            child: ClipPath(
              clipper: BackgroundClipper(),
              child: Container(
                color: Theme
                    .of(context)
                    .colorScheme
                    .background,
              ),
            ),
          ),
          // Then the rest
          Container(
            child: new Column(
              children: <Widget>[
                SizedBox(height: 40),
                _topLeaderBoard(),
                SizedBox(height: 40),
                // The list of Quiz players
                _quizPlayers(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _topLeaderBoard() {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      //Center Column contents vertically,
      crossAxisAlignment: CrossAxisAlignment.center,
      //Center Column contents horizontally,
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
            height: 50,
            width: 50,
            // child: Icon(Icons.)
            decoration: new BoxDecoration(

              // You need this line or the box will be transparent
              color: Colors.lightGreen,
              shape: BoxShape.circle,
            ),
          ),
            Text("Winner 1"),
          ],
        ),

        SizedBox(width: 50),
        Column(
          children: <Widget>[
            Container(
              height: 100,
              width: 100,
              decoration: new BoxDecoration(

                // You need this line or the box will be transparent
                color: Colors.lightGreen,
                shape: BoxShape.circle,
              ),
            ),
            Text("Winner 2"),
          ],
        ),
        SizedBox(width: 50),
        Column(
          children: <Widget>[
            Container(
              height: 50,
              width: 50,
              decoration: new BoxDecoration(

                // You need this line or the box will be transparent
                color: Colors.lightGreen,
                shape: BoxShape.circle,
              ),
            ),
            Text("Winner 3"),
          ],
        ),


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
}

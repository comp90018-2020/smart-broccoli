import 'package:flutter/material.dart';
import 'package:smart_broccoli/src/quiz_taker/quiz_question.dart';
import 'package:smart_broccoli/src/quiz_taker/quiz_taker.dart';
import 'package:smart_broccoli/src/quiz_taker/quiz_users.dart';
import 'package:smart_broccoli/src/quiz_taker/start_lobby.dart';
import 'package:smart_broccoli/theme.dart';

/// The Skeleton for the Leaderboard lobby
/// Unfinished as it is beyond my skill ability
/// There are pending changes
class LeaderBoardLobby extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LeaderBoardLobby();
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
                //_quizPlayers(),
                QuizUsers(),
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
      // TODO I need to find a way to fix this relative to everything else
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

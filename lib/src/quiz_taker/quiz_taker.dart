import 'package:flutter/material.dart';
import 'package:smart_broccoli/src/quiz_taker/quiz_question.dart';

import '../../theme.dart';
import 'start_lobby.dart';

class quizTaker extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _quizTakerState();
}

/// Super hacky (but official) way to have weird shapes in the background
/// For clarifications please talk to Harrison
class BackgroundClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(0, size.height * 0.66);
    //  path.moveTo(0, size.width*1.5);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 150);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class _quizTakerState extends State<quizTaker> {
  /// A pin listener
  /// listens for input by the pin listener
  final TextEditingController _pinFilter = new TextEditingController();

  String _pin = "";

  void _pinListen() {
    if (_pinFilter.text.isEmpty) {
      _pin = "";
    } else {
      _pin = _pinFilter.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Stack(
          // overflow: Overflow.visible,
          children: <Widget>[
            Container(
              child: ClipPath(
                clipper: BackgroundClipper(),
                child: Container(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            ),
            Container(
              child: SingleChildScrollView(
                  child: new Column(
                children: <Widget>[
                  // Title "UNI QUIZ"
                  SizedBox(height: 50),
                  _SwitchButton(),
                ],
              )),
            ),
          ],
        ));
  }

  Widget _SwitchButton() {
    return new DefaultTabController(
      length: 3,
      child: Column(
        children: <Widget>[
          TabHolder(
              // TODO change Tabs class to allow to varible sizes for tabs
              margin: const EdgeInsets.only(top: 35, bottom: 35),
              tabs: [Tab(text: "ALL"), Tab(text: "LIVE"), Tab(text: "SELF")]),

          // Presistant Elements
          // The pin form
          new Container(
            child: _pinForm(),
          ),
          // Padding
          SizedBox(height: 50),
          // Join by pin button
          new Container(
            child: _buildJoinByPinButton(),
          ),
          // Padding
          SizedBox(height: 50),

          // Tabs
          new Container(
            // TODO fix this hack line
            // So basically the idea here is that the string
            // Passed into each of the methods will generate a different
            // List of items
            height: 250,

            child: TabBarView(
              children: [
                _buildQuizList("ALL"),
                _buildQuizList("LIVE"),
                _buildQuizList("SELF"),
              ],
            ),
            // child: _buildQuizList(),
          ),
          // Tab contents
        ],
      ),
    );
  }

  // The form which you enter the pin into
  Widget _pinForm() {
    return new Container(
      padding: EdgeInsets.fromLTRB(150, 16, 150, 0),
      child: new Column(
        children: <Widget>[
          new Container(
            child: TextFormField(
              controller: _pinFilter,
              decoration: new InputDecoration(
                labelText: 'Pin',
                // prefixIcon: Icon(Icons.people),
              ),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
            ),
          ),
        ],
      ),
    );
  }

  /// The Join by Pin button
  /// Currently it points towards a question tab
  Widget _buildJoinByPinButton() {
    return new Container(
      child: new Column(
        children: <Widget>[
          new ButtonTheme(
            minWidth: 150.0,
            height: 50.0,
            child: RaisedButton(
              onPressed: _verifyPin, // TODO CHANGE
              child: Text("Join By Pin"),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
            ),
          ),
        ],
      ),
    );
  }



  /// Widget which constructs a quiz list
  Widget _buildQuizList(type) {
    List<String> items = getItems(type);

    return Container(
      // margin: EdgeInsets.fromLTRB(20,0,),
      // height: 300.0,
      child: ListView.separated(
        // Enable Horizontal Scroll
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _cardTile(items[index], type);
        },
        // Space between the cards
        separatorBuilder: (context, index) {
          return Divider(indent: 1);
        },
      ),
    );
  }

  /// This is a single tile within a list
  /// val is the position ID
  /// type is one of "ALL" "SELF" "LIVE"
  /// This is used to demostrate that tab changes the list as well
  Widget _cardTile(val, type) {
    return new Container(
      height: 150,
      width: 200,
      child: Card(
        elevation: 16,
        child: InkWell(
          // For cool color effects uncomment these two lines
          // highlightColor: Colors.pinkAccent,
          // splashColor: Colors.greenAccent,
          onTap: () => _quiz(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // The image here is a placeholder, it is necessary to
                  // Provide a height and a width value
                  Image(image: AssetImage('assets/images/placeholder.png')),
                  Text(
                    val + type,
                    style: TextStyle(fontSize: 20),
                  ),
                  Text('Subtitle', style: TextStyle(fontSize: 15)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text('Live', style: TextStyle(fontSize: 15)),
                ],
              )
            ],
          ),
        ),
      ),
    );

  }

  /// Take a quiz, goes to the quiz lobby which then connects you to a quiz
  /// Interface
  void _quiz() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => start_lobby()),
    );
  }

  /// The verify pin function currently is used for debug purposes
  /// Please change this to the desired result which should be like the method
  /// Above
  void _verifyPin() {
    print(_pinFilter.text);

    // TODO remove debug code below
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => start_lobby()),
    );
  }

  /// Entry function for the different type of quizes
  /// Please change the output type
  /// Should default to "ALL"
  List<String> getItems(type) {
    print("NOT IMPLEMENTED");
    return ["A", "B", "C", "D", "E", "F", "G"];
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:smart_broccoli/src/quiz_taker/build_quiz.dart';
import '../../theme.dart';
import 'start_lobby.dart';

GlobalKey _allKey = GlobalKey();
GlobalKey _groupKey = GlobalKey();
GlobalKey _selfKey = GlobalKey();

class QuizTaker extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _QuizTakerState();
}

/// Super hacky (but official) way to have weird shapes in the background
/// For clarifications please talk to Harrison
class BackgroundClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(0, size.height * 0.66);
    // path.moveTo(0, size.width*1.5);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, size.height - size.height * 0.55);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class _QuizTakerState extends State<QuizTaker> {
  double _height = 0;

  // Tabs that are shown (in TabBarView)
  List<Widget> _tabs;

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
  void initState() {
    super.initState();

    // Initial tabs (to solve TabBarView unbounded height issue)
    // When the height of the register tabview child is retrieved,
    // swap the pages around and constrain the height
    // https://github.com/flutter/flutter/issues/29749
    // https://github.com/flutter/flutter/issues/54968
    // NOTE: I can't seem to get this code to work as cards and grids
    // Require a size value Therefore this is commented out for now
    // Someone should probably look into getting this part of the code to work
    // With the class BuildQuiz
    /*
     _tabs = [
      Wrap(
        children: [
          BuildQuiz(key: _allKey),
          Visibility(
            visible: false,
            maintainState: true,
            maintainAnimation: true,
            maintainSize: true,
            child: Wrap(
              children: [
                BuildQuiz(key: _groupKey),
              ],
            ),
          ),
        ],
      ),
      Container(),
      Container(),
    ];

    // Get height of register box
    SchedulerBinding.instance.addPostFrameCallback((_) {
      RenderBox _allBox = _allKey.currentContext.findRenderObject();
      RenderBox _selfBox = _selfKey.currentContext.findRenderObject();
      RenderBox _groupBox = _groupKey.currentContext.findRenderObject();

      double maxHeight = _allBox.size.height;

      if (_height != maxHeight) {
        setState(() {
          _height = maxHeight;
          _tabs = [
            BuildQuiz(key: _allKey),
            BuildQuiz(key: _groupKey),
            BuildQuiz(key: _selfKey)
          ];
        });
      }
    });
    */

    _tabs = [
      BuildQuiz(key: _allKey),
      BuildQuiz(key: _groupKey),
      BuildQuiz(key: _selfKey)
    ];

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

          FractionallySizedBox(
           // widthFactor: 0.7,
            child: LimitedBox(
              // Need to limit height of TabBarView
              maxHeight: MediaQuery.of(context).size.height*0.3,
              child: TabBarView(children: getTabs()),
            ),
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
          RaisedButton(
            onPressed: _verifyPin, // TODO CHANGE
            child: Text("Join By Pin"),
          ),
        ],
      ),
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
      MaterialPageRoute(builder: (context) => StartLobby()),
    );
  }

  List<Widget> getTabs() {
    print(_tabs);
    return  _tabs;
  }
}

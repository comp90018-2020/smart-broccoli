import 'package:flutter/material.dart';
import 'package:fuzzy_broccoli/src/QuizTaker/quizQuestion.dart';

import 'lobby.dart';

class quizMaker extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _quizMakerState();
}



class BackgroundClipper extends CustomClipper<Path>{
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(0, size.height*0.66);
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

class _quizMakerState extends State<quizMaker> {
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
          children: <Widget>[
            Container(
              child:ClipPath(
                  clipper: BackgroundClipper(),
                  child: Container(
                      color: Theme.of(context).colorScheme.onBackground,
                      ))
            ),
            Container(
              child: new Column(
                children: <Widget>[
                  // Title "UNI QUIZ"
                  SizedBox(height: 50),
                  _SwitchButton(),
                ],
              ),
            )
          ],
        )
);
  }


  Widget _buildTextFields() {
    return Container(
      child: new Column(
        children: <Widget>[
          // Padding
          SizedBox(height: 50),
          _SwitchButton(),
        ],
      ),
    );
  }

  Widget _SwitchButton() {
    return new DefaultTabController(
        length: 3,
        child: Column(
          children: <Widget>[
            // Tabs
            FractionallySizedBox(
                widthFactor: 0.85,
                child: Container(
                    margin: EdgeInsets.only(top: 35, bottom: 20),
                    decoration: BoxDecoration(
                        color: Color(0xFF82C785),
                        borderRadius: BorderRadius.all(Radius.circular(25))),
                    child: TabBar(
                      tabs: [
                        new Tab(
                          text: "All",
                        ),
                        new Tab(
                          text: "Live",
                        ),
                        new Tab(
                          text: "Self Paced",
                        )
                      ],
                    ))),
            new Container(
              child: _buildLiveQuiz(),
            ),
            // Padding
            SizedBox(height: 50),
            new Container(
              child: _buildJoinByPinButton(),
            ),
            // Padding
            SizedBox(height: 50),
            new Container(
              // color: Theme.of(context).colorScheme.onBackground,
              // TODO fix this hack line
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
        ));
  }

  Widget _buildLiveQuiz() {
    return new Container(
        padding: EdgeInsets.fromLTRB(150, 16, 150, 0),
        child: new Column(children: <Widget>[
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
        ]));
  }

  Widget _buildJoinByPinButton() {
    return new Container(
        child: new Column(
      children: <Widget>[
        new ButtonTheme(
          minWidth: 150.0,
          height: 50.0,
          buttonColor: Colors.orangeAccent,
          child: RaisedButton(
            onPressed: _verifyPin, // TODO CHANGE
            child: Text("Join By Pin"),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ),
          ),
        ),
      ],
    ));
  }


  //final items = List<String>.generate(10, (i) => "Item $i");

  Widget _buildQuizList(type) {
    List<String> items = getItems(type);


    return Container(
        // margin: EdgeInsets.fromLTRB(20,0,),
        height: 200.0,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          itemBuilder: (context, index) {
            return _listTile(items[index], type);
          },
          separatorBuilder: (context, index) {
            return Divider(indent: 10);
          },
        ));
  }

  // TODO change to flat button
  /// This is a single tile within a list
  Widget _listTile(val, type) {
    return new Container(
        width: 160.0,
        child: new RaisedButton(
          // The padding somehow allows the image to not leave any gaps on the
          // List Tile, this is defintively a hack TODO check if it actually does it
            padding: EdgeInsets.all(0.0),
            color: Colors.white,
            onPressed: () => _quiz(),
            child: new Column(children: <Widget>[
              new Container(
                // You will need to change this to a method to get an image
                child: Image(image: AssetImage('assets/images/placeholder.png')),
              ),
              new Container(
                  child: Center(
                child: Text(
                  val + type,
                  style: TextStyle(height: 5, fontSize: 5, color: Colors.black),
                ),
              )),
              Expanded(child: Container()),
              new Container(
                child: Text(
                  "STATUS Here",
                  style: TextStyle(height: 5, fontSize: 5, color: Colors.black),
                ),
              ),
            ])));
  }

  /// Take a quiz, goes to the quiz lobby which then connects you to a quiz
  /// Interface
  void _quiz() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => lobby()),
    );
  }


  /// The verify pin function currently is used for debug purposes
  /// Please change this to the desired result which should be like the method
  /// Above
  void _verifyPin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => quizQuestion()),
    );
    print("TOOD");
  }

  /// Entry function for the different type of quizes
  /// Please change the output type
  List<String> getItems(type) {
    print("NOT IMPLEMENTED");
    return ["A", "B", "C", "D", "E", "F", "G"];
  }
}

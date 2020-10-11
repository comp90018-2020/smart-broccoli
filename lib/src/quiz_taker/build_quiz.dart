import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:smart_broccoli/src/shared/background.dart';
import 'package:smart_broccoli/src/quiz_taker/start_lobby.dart';

// Build a list of quizes
class BuildQuiz extends StatefulWidget {
  BuildQuiz({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _BuildQuiz(key);
}

class _BuildQuiz extends State<BuildQuiz> {
  Key key;

  /// A pin listener
  /// listens for input by the pin listener
  final TextEditingController _pinFilter = new TextEditingController();

  _BuildQuiz(this.key);

  // Builder function for a list of card tiles
  @override
  Widget build(BuildContext context) {
  //  double width = MediaQuery.of(context).size.width;
  //  double height = MediaQuery.of(context).size.height;
    List<String> items = getItems(this.key);
    return Stack(
      // overflow: Overflow.visible,
      children: <Widget>[
        Column(
          children: <Widget>[
            new Container(
              child: _pinForm(),
            ),
            SizedBox(height: 10),
            new FractionallySizedBox(
              widthFactor: 0.5,
              child: Text(
                  "By entering PIN you can access a quiz and join into the group of the that quiz"),
            ),
            // Padding
            SizedBox(height: 50),
            // Join by pin button
            new Container(
              child: _buildJoinByPinButton(),
            ),
            // Padding
            SizedBox(height: 50),

            Container(
              child: Expanded(
                //width: 200,
                child: ListView.separated(
                  // Enable Horizontal Scroll
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return _cardTile(
                        items[index], this.key.toString(), index.toString());
                  },
                  // Space between the cards
                  separatorBuilder: (context, index) {
                    return Divider(indent: 1);
                  },
                ),
              ),
            ),
            SizedBox(height: 80),
          ],
        ),
      ],
    );
  }

  /// This is a single tile within a list
  /// val is the position ID
  /// type is one of "ALL" "SELF" "LIVE"
  /// This is used to demostrate that tab changes the list as well
  Widget _cardTile(String val, String type, String index) {
    double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;

    return new Container(
      key: Key(index + val + index),
      //height: 150,
      //  controls the width of cards
      width: width * 0.4,
      child: Card(
        elevation: 2,
        child: InkWell(
          // For cool color effects uncomment these two lines
          // highlightColor: Colors.pinkAccent,
          // splashColor: Colors.greenAccent,
          onTap: () => _quiz(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              pictureWithTitle(val, type),
              status(),
            ],
          ),
        ),
      ),
    );
  }

  // You can put a picture and title in this widget
  Widget pictureWithTitle(val, type) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // The image here is a placeholder, it is necessary to
        // Provide a height and a width value
        Container(
          height: height * 0.2,
          width: width * 0.2,
          child: Image(image: AssetImage('assets/images/placeholder.png')),
        ),
        Text(
          val + type,
          style: TextStyle(fontSize: 20),
        ),
        Text('Subtitle', style: TextStyle(fontSize: 15)),
      ],
    );
  }

  Widget status() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text('Live', style: TextStyle(fontSize: 15)),
      ],
    );
  }

  /// Take a quiz, goes to the quiz lobby which then connects you to a quiz
  /// Interface
  void _quiz() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => StartLobby()),
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

  /// Entry function for the different type of quizes
  /// Please change the output type
  /// Should default to "ALL"
  /// Type should be of type Key
  List<String> getItems(Key type) {
    print("NOT IMPLEMENTED");
    return ["A", "B", "C", "D", "E", "F", "G"];
  }
}

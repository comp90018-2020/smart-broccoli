import 'package:flutter/material.dart';
import 'package:fuzzy_broccoli/src/QuizTaker/quizQuestion.dart';

import 'lobby.dart';

class quizMaker extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _quizMakerState();
}

enum quizType { All, Live, SelfPaced }

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
        body: _buildTextFields());
  }

  Widget _buildTextFields() {
    return new SingleChildScrollView(
        child: Container(
      child: new Column(
        children: <Widget>[
          // Title "UNI QUIZ"
          SizedBox(height: 50),
          _SwitchButton(),
        ],
      ),
    ));
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
            SizedBox(height: 50),
            new Container(
              child: _buildJoinByPinButton(),
            ),
            SizedBox(height: 50),
            new Container(
              height: 200,
              child: TabBarView(
                children: [
                  _buildQuizList(),
                  _buildQuizList(),
                  _buildQuizList(),
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

  final items = List<String>.generate(10, (i) => "Item $i");

  Widget _buildQuizList() {
    return Container(
        // margin: EdgeInsets.fromLTRB(20,0,),
        height: 200.0,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          itemBuilder: (context, index) {
            return _listTile();
          },
          separatorBuilder: (context, index) {
            color:
            Colors.white;
            return Divider(indent: 10);
          },
        ));
  }

  // TODO change to flat button
  Widget _listTile() {
    return new Container(
        width: 160.0,
        child: new RaisedButton(
            padding: EdgeInsets.all(0.0),
            color: Colors.white,
            onPressed: () => _quiz(),
            child: new Column(children: <Widget>[
              new Container(
                // TODO GET IMAGE
                child:
                    Image(image: AssetImage('assets/images/placeholder.png')),
              ),
              new Container(
                  child: Center(
                child: Text(
                  "COMP1337",
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

  void _quiz() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => lobby()),
    );
  }

  void _formChange() {
    print('UWU');
  }

  void _verifyPin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => quizQuestion()),
    );
    print("TOOD");
  }
}

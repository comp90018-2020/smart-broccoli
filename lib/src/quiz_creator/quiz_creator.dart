import 'dart:io';

import 'package:flutter/material.dart';

import '../data/quiz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:numberpicker/numberpicker.dart';

class QuizCreate extends StatefulWidget {
  QuizCreate({Key key}) : super(key: key);

  @override
  _QuizCreateState createState() => _QuizCreateState();
}

class _QuizCreateState extends State<QuizCreate> {
  // Timer picker START
  int _currentIntValue = 30;
  NumberPicker integerNumberPicker;

  var txt = TextEditingController();

  _handleValueChangedExternally(num value) {
    if (value != null) {
      if (value is int) {
        setState(() {
          _currentIntValue = value;
          txt.text = _currentIntValue.toString() + " seconds";
        });
      }
    }
  }

  Future _showIntegerDialog() async {
    await showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return new NumberPickerDialog.integer(
              minValue: 5, maxValue: 90, initialIntegerValue: 30);
        }).then((value) => _handleValueChangedExternally(value));
  }

  // Timer picker END**********************************/

  // Image setter START**********************************/

  File imageFile;
  final picker = ImagePicker();

  _openGallery(BuildContext context) async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    this.setState(() {});
    Navigator.of(context).pop();
  }

  _openCamera(BuildContext context) async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.camera);
    this.setState(() {});

    Navigator.of(context).pop();
  }

  Future<void> _showChoiceDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Select upload method"),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  GestureDetector(
                    child: Text("From gallery"),
                    onTap: () {
                      _openGallery(context);
                    },
                  ),
                  Padding(padding: EdgeInsets.all(8.0)),
                  GestureDetector(
                    child: Text("Using camera"),
                    onTap: () {
                      _openCamera(context);
                    },
                  )
                ],
              ),
            ),
          );
        });
  }

  Widget _decideImageView() {
    if (imageFile == null) {
      return IconButton(
        padding: new EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 0.0),
        icon: new Icon(Icons.insert_photo_outlined, size: 100),
        onPressed: () {},
      );
    } else {
      return Image.file(imageFile, fit: BoxFit.cover);
    }
  }

  Quiz model = Quiz("placeholder", 0, QuizType.LIVE);

  QuizType radioBtn = QuizType.LIVE;

  final _formKey = GlobalKey<FormState>();
  _QuizCreateState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: SizedBox(
          child: Text("Quiz"),
        ),
        leading: GestureDetector(
          onTap: () {},
          child: Icon(Icons.close),
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 20.0, top: 0.0),
            child: GestureDetector(onTap: () {}, child: Icon(Icons.delete)),
          ),
          Padding(
            padding: EdgeInsets.only(right: 20.0, top: 22.0),
            child: GestureDetector(onTap: () {}, child: Text("SAVE")),
          ),
        ],
      ),
      body: SingleChildScrollView(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Container(
                  padding: EdgeInsets.fromLTRB(12.00, 10.00, 0, 3.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Text(
                        'Settings',
                        style: new TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      )
                    ],
                  )),
              Padding(
                  padding: EdgeInsets.fromLTRB(12.0, 8, 10.0, 0.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Quiz name',
                    ),
                  )),
              Container(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Container(
                          width: 390,
                          child: Card(
                            semanticContainer: true,
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            child: Column(children: <Widget>[
                              Container(
                                width: 380,
                                height: 100,
                                child: _decideImageView(),
                              ),
                              ButtonBar(
                                alignment: MainAxisAlignment.center,
                                children: [
                                  FlatButton(
                                    textColor: Colors.black54,
                                    onPressed: () {
                                      _showChoiceDialog(context);
                                      // Perform some action
                                    },
                                    child: const Text('SET QUIZ IMAGE'),
                                  ),
                                ],
                              )
                            ]),
                            shape: RoundedRectangleBorder(),
                            elevation: 5,
                            margin: EdgeInsets.fromLTRB(12.0, 8, 10.0, 0.0),
                          )),
                    ],
                  ),
                ),
              ),
              Padding(
                  padding: EdgeInsets.fromLTRB(12.0, 8, 10.0, 0.0),
                  child: TextField(
                    autofocus: false,
                    controller: txt,
                    // readOnly: true,
                    onTap: _showIntegerDialog,
                    decoration: InputDecoration(
                        labelText: 'Seconds per question',
                        prefixIcon: Icon(Icons.timer)),
                  )),
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.fromLTRB(12.0, 6.0, 10.0, 0.0),
                height: 100,
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: const Text('LIVE'),
                      dense: true,
                      leading: Radio(
                        activeColor: Colors.green,
                        value: QuizType.LIVE,
                        groupValue: radioBtn,
                        onChanged: (QuizType value) {
                          setState(() {
                            radioBtn = value;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      dense: true,
                      title: const Text('SELF-PACED'),
                      leading: Radio(
                        activeColor: Colors.green,
                        value: QuizType.SELF_PACED,
                        groupValue: radioBtn,
                        onChanged: (QuizType value) {
                          setState(() {
                            radioBtn = value;
                          });
                        },
                      ),
                    )
                  ],
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.fromLTRB(12.00, 25.00, 0, 3.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Text(
                            'Questions',
                            style: new TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          )
                        ],
                      )),
                  const SizedBox(height: 30),
                  RaisedButton(
                    onPressed: () {},
                    padding: EdgeInsets.all(20.0),
                    child: const Text(
                      'Add Question',
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                ],
              )
            ],
          )),
    );
  }
}

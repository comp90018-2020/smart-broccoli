// code structure inspired by https://medium.com/@mahmudahsan/how-to-create-validate-and-save-form-in-flutter-e80b4d2a70a4
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:image_picker/image_picker.dart';

class QuestionCreateForm extends StatefulWidget {
  QuestionCreateForm({Key key}) : super(key: key);

  @override
  _QuestionCreateFormState createState() => _QuestionCreateFormState();
}

class _QuestionCreateFormState extends State<QuestionCreateForm> {
  // Answer cards START
  // Creates an answer card

  var nameTECs = <TextEditingController>[];
  var cards = <Card>[];

  Card createCard() {
    var textController = TextEditingController();
    nameTECs.add(textController);
    return Card(
      margin: EdgeInsets.fromLTRB(12.00, 6, 12.00, 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Answer ${cards.length + 1}'),
          TextField(
              controller: textController,
              decoration: InputDecoration(labelText: 'Answer')),
          ButtonBar(
            alignment: MainAxisAlignment.end,
            buttonPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            children: [
              FlatButton(
                textColor: Colors.black54,
                onPressed: () {
                  cards.remove(this);
                  // Perform some action
                },
                child: Icon(Icons.delete),
              ),
            ],
          )
        ],
      ),
    );
  }

  // Answer cards END**********************************************************

  // Set image START
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

  // Set image END

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(),
        () => SystemChannels.textInput.invokeMethod('TextInput.hide'));

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: SizedBox(
          child: Text("Question"),
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
          child: Column(
        mainAxisSize: MainAxisSize.min,
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
                  labelText: 'Question text',
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
                                child: const Text('SET QUESTION IMAGE'),
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
          ),
          Container(
              padding: EdgeInsets.fromLTRB(12.00, 10.00, 0, 3.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Text(
                    'Answers',
                    style: new TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ],
              )),
          Column(
            children: <Widget>[
              ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: cards.length,
                itemBuilder: (BuildContext context, int index) {
                  return cards[index];
                },
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: RaisedButton(
                  padding: EdgeInsets.all(14.0),
                  child: Text('ADD ANSWER'),
                  onPressed: () => setState(() => cards.add(createCard())),
                ),
              )
            ],
          ),
        ],
      )),
    );
  }
}

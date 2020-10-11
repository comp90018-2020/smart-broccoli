// code structure inspired by https://medium.com/@mahmudahsan/how-to-create-validate-and-save-form-in-flutter-e80b4d2a70a4
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/quiz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:numberpicker/numberpicker.dart';





class QuestionCreateForm extends StatefulWidget {
  String name;

  QuestionCreateForm({Key key, this.name}) : super(key: key);
  @override
  _QuestionCreateFormState createState() => _QuestionCreateFormState(key, name);
}

class _QuestionCreateFormState extends State<QuestionCreateForm> {

  var txt = TextEditingController();

  int _currentIntValue = 30;
  NumberPicker integerNumberPicker;


  File imageFile;
  final picker = ImagePicker();


  final _formKey = GlobalKey<FormState>();
  Quiz model = Quiz("placeholder", 0, QuizType.LIVE);

  //Radio buttons selection
  QuizType radioBtn = QuizType.LIVE;
  Key key;
  String name;
  _QuestionCreateFormState(this.key, this.name);


  _handleValueChanged(num value){
    if(value != null){

      if (value is int){
        setState(() {
          _currentIntValue = value;
        });
      }

    }
  }

  _handleValueChangedExternally(num value){

    if(value != null){

      if (value is int){
        setState(() {
          _currentIntValue = value;
          txt.text = _currentIntValue.toString() + " seconds";
        });
      }

    }

  }

  _openGallery(BuildContext context) async{

    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    this.setState(() {
    });
    Navigator.of(context).pop();

  }
  _openCamera(BuildContext context) async{

    imageFile = await ImagePicker.pickImage(source: ImageSource.camera);
    this.setState(() {
    });

    Navigator.of(context).pop();

  }



  Future<void> _showChoiceDialog(BuildContext context){
    return showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Select upload method"),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              GestureDetector(
                child: Text ("From gallery"),
                onTap: (){
                  _openGallery(context);
                },
              ),
              Padding(padding: EdgeInsets.all(8.0)),
              GestureDetector(
                child: Text ("Using camera"),
                onTap: (){
                  _openCamera(context);
                },
              )
            ],

          ),
        ),
      );

    });

  }


  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(), () => SystemChannels.textInput.invokeMethod('TextInput.hide'));

    return Scaffold(

      appBar: AppBar(
        centerTitle: true,
        title: SizedBox(
          child:  Text("Quiz"),
        ),
        leading: GestureDetector(
          onTap: (){
          },
          child: Icon(Icons.close),
        ),

        actions: <Widget> [
          Padding(
            padding: EdgeInsets.only(right: 20.0, top: 0.0),
            child: GestureDetector(
                onTap: (){},
                child: Icon(Icons.delete)
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 20.0, top: 22.0),
            child: GestureDetector(
                onTap: (){},
                child: Text("SAVE")
            ),
          ) ,

        ],

      ),

      body: SingleChildScrollView(


          key: _formKey,
          child: Column(


            children: <Widget>[
              Padding(padding: EdgeInsets.fromLTRB(12.0, 8, 10.0, 0.0),
                  child:  TextField(
                    decoration: InputDecoration(
                      labelText: 'Quiz name',
                    ),
                  ))
              ,


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
                            child: Column(
                                children: <Widget> [
                                  Container(
                                    width: 380,
                                    height: 100,
                                    child: _decideImageView(),
                                  )
                                  ,
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
                                  )]

                            ),
                            shape: RoundedRectangleBorder(

                            ),
                            elevation: 5,
                            margin: EdgeInsets.fromLTRB(12.0, 8, 10.0, 0.0),

                          )


                      ),

                    ],
                  ),
                ),

              ),

              Padding(padding: EdgeInsets.fromLTRB(12.0, 8, 10.0, 0.0),


                  child: TextField(
                    autofocus: false,
                    controller: txt,
                    // readOnly: true,
                    onTap: _showIntegerDialog,
                    decoration: InputDecoration(
                        labelText: 'Seconds per question',
                        prefixIcon: Icon(Icons.timer)
                    ),

                  )



              ),

              Container(
                  padding: EdgeInsets.fromLTRB(12.00, 10.00, 0, 3.0),
                  child:  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget> [
                      new Text(
                        'Select type of quiz',
                        style: new TextStyle(
                          fontSize: 17.0, fontWeight: FontWeight.w400, color: Colors.white,
                        ),
                      )
                    ],
                  )
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.fromLTRB(12.0, 0.0, 10.0, 0.0),
                height: 100,
                child: Column(
                  children: <Widget> [

                    ListTile(
                      title: const Text('LIVE'),
                      dense: true,
                      leading: Radio(
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
                )

                ,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white),

              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget> [ const SizedBox(height: 30),

                  RaisedButton(
                    onPressed: () {},
                    padding: EdgeInsets.all(20.0),
                    child: const Text('Add Question', style: TextStyle(fontSize: 20), ),
                  )
                ],)






            ],
          )
      ),
      /*body: _buildSuggestions(),*/
    );
  }
  
  
  Widget _decideImageView(){

    if (imageFile == null){

      return IconButton(
        padding: new EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 0.0),
        icon: new Icon(Icons.insert_photo_outlined, size: 100),
      );

    }else{

      return Image.file(imageFile, fit: BoxFit.cover);


    }
  }


  Future _showIntegerDialog() async {
    await showDialog<int>(
        context: context,
        builder: (BuildContext context){
          return new NumberPickerDialog.integer(minValue: 5, maxValue: 90, initialIntegerValue: 30);
        }

    ).then((value) => _handleValueChangedExternally(value));

  }





}


class NoKeyboardEditableText extends EditableText {

  NoKeyboardEditableText({
    @required TextEditingController controller,
    TextStyle style = const TextStyle(),
    Color cursorColor = Colors.black,
    bool autofocus = false,
    Color selectionColor
  }):super(
      controller: controller,
      focusNode: NoKeyboardEditableTextFocusNode(),
      style: style,
      cursorColor: cursorColor,
      autofocus: autofocus,
      selectionColor: selectionColor,
      backgroundCursorColor: Colors.black
  );

  @override
  EditableTextState createState() {
    return NoKeyboardEditableTextState();
  }

}

class NoKeyboardEditableTextState extends EditableTextState {

  @override
  Widget build(BuildContext context) {
    Widget widget = super.build(context);
    return Container(
      decoration: UnderlineTabIndicator(borderSide: BorderSide(color: Colors.blueGrey)),
      child: widget,
    );
  }

  @override
  void requestKeyboard() {
    super.requestKeyboard();
    //hide keyboard
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }
}

class NoKeyboardEditableTextFocusNode extends FocusNode {
  @override
  bool consumeKeyboardToken() {
    // prevents keyboard from showing on first focus
    return false;
  }
}

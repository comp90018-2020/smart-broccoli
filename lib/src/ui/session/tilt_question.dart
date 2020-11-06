import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sensors/sensors.dart';
import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui/session/timer.dart';
import 'package:smart_broccoli/src/ui/shared/dialog.dart';
import 'package:smart_broccoli/src/ui/shared/page.dart';
import 'package:smart_broccoli/src/ui/shared/tilt_graphics.dart';

class TiltQuestion extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<TiltQuestion> {
  List<bool> chosen = [false, false, false, false];

  int selectableAnswers = 1;
  int listOfAnswers = 4;

  double width;
  double height;

  double sizeOfTriangle;

  bool isMultipleChoice = true;
  bool isManyChoice = true;
  bool trueOrFalse;

  List<double> cord = [0.0, 0.0];

  // color of the circle
  Color color = Colors.greenAccent;

  // event returned from accelerometer stream
  AccelerometerEvent event;

  // hold a refernce to these, so that they can be disposed
  Timer timer;
  StreamSubscription accel;

  // positions and count
  double top;
  double left;
  int selectAnswerTime = 0;

  setPosition(AccelerometerEvent event) {
    if (event == null) {
      return;
    }

    // print("x " + cord[0].toString());
    // print("y " + cord[1].toString());

    // print("x + " + event.x.toString());
    // print("y +" + event.y.toString());

    cord[0] = cord[0] - event.x * 2;
    cord[1] = cord[1] + event.y * 2;

    if (cord[0] >= width - 40) {
      cord[0] = width - 40;
    }
    if (cord[0] <= 1) {
      cord[0] = 1;
    }
    if (cord[1] >= height - appBarHeight - 40) {
      cord[1] = height - appBarHeight - 40;
    }
    if (cord[1] <= 1) {
      cord[1] = 1;
    }

    // print("Updated x " + cord[0].toString());
    // print("Updated y " + cord[1].toString());

    // When x = 0 it should be centered horizontally
    // The left positin should equal (width - 100) / 2
    // The greatest absolute value of x is 10, multipling it by 12 allows the left position to move a total of 120 in either direction.
    setState(() {
      left = cord[0];
    });

    // When y = 0 it should have a top position matching the target, which we set at 125
    setState(() {
      top = cord[1];
    });

    Point p1 = Point(left, top);
    Point p2 = Point(0, 0);
    Point p3 = Point(width, height - appBarHeight);
    Point p4 = Point(0, height - appBarHeight);
    Point p5 = Point(width, 0);

    if (p1.distanceTo(p2) < sizeOfTriangle) {
      selectAnswerTime++;
      if (selectAnswerTime > 10) {
        updateChosen(0);
        selectAnswerTime = 0;
      }
    } else if (p1.distanceTo(p3) < sizeOfTriangle && listOfAnswers > 3) {
      print("P3");
      selectAnswerTime++;
      if (selectAnswerTime > 10) {
        updateChosen(3);
        selectAnswerTime = 0;
      }
    } else if (p1.distanceTo(p4) < sizeOfTriangle && listOfAnswers > 2) {
      print("P4");
      selectAnswerTime++;
      if (selectAnswerTime > 10) {
        updateChosen(2);
        selectAnswerTime = 0;
      }
    } else if (p1.distanceTo(p5) < sizeOfTriangle) {
      print("P5");
      selectAnswerTime++;
      if (selectAnswerTime > 10) {
        updateChosen(1);
        selectAnswerTime = 0;
      }
    } else {}
  }

  startTimer() {
    // if the accelerometer subscription hasn't been created, go ahead and create it
    if (accel == null) {
      accel = accelerometerEvents.listen((AccelerometerEvent eve) {
        setState(() {
          event = eve;
        });
      });
    } else {
      // it has already ben created so just resume it
      accel.resume();
    }

    // Accelerometer events come faster than we need them so a timer is used to only proccess them every 200 milliseconds
    if (timer == null || !timer.isActive) {
      timer = Timer.periodic(Duration(milliseconds: 50), (_) {
        // if count has increased greater than 3 call pause timer to handle success

        // proccess the current event
        setPosition(event);
      });
    }
  }

  pauseTimer() {
    // stop the timer and pause the accelerometer stream
    timer.cancel();
    accel.pause();
  }

  @override
  void dispose() {
    timer?.cancel();
    accel?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();

    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    print("height" + height.toString());
    print("width" + width.toString());
    cord[0] = width / 2.0;
    cord[1] = height / 2.0;
    top = cord[1];
    left = cord[0];

    if (width > height) {
      sizeOfTriangle = height / 4;
    } else {
      sizeOfTriangle = width / 4;
    }
  }

  double appBarHeight;

  List<Widget> tiltWidgets(GameSessionModel model) {
    if (model.question is TFQuestion) {
      listOfAnswers = 2;
      selectableAnswers = 1;
    } else {
      listOfAnswers = (model.question as MCQuestion).options.length;
      selectableAnswers = (model.question as MCQuestion).numCorrect;
    }

    // print("Multiple Choice?: " + (model.question is MCQuestion).toString());

    // print(listOfAnswers);
    if (listOfAnswers == 4) {
      return [
        fourCorners1(),
        fourCorners2(),
        fourCorners3(),
        fourCorners4(),
        positionedText1((model.question as MCQuestion).options[0].text),
        positionedText2((model.question as MCQuestion).options[1].text),
        positionedText3((model.question as MCQuestion).options[2].text),
        positionedText4((model.question as MCQuestion).options[3].text)
      ];
    } else if (listOfAnswers == 3) {
      return [
        fourCorners1(),
        fourCorners2(),
        fourCorners3(),
        positionedText1((model.question as MCQuestion).options[0].text),
        positionedText2((model.question as MCQuestion).options[1].text),
        positionedText3((model.question as MCQuestion).options[2].text),
      ];
    } else {
      return [
        fourCorners1(),
        fourCorners2(),
        positionedText1(("True")),
        positionedText2(("False")),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    appBarHeight = MediaQuery.of(context).padding.top + kToolbarHeight;

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return Consumer<GameSessionModel>(
      builder: (context, model, child) => CustomPage(
        title: 'Question ${model.question.no + 1}',

        appbarLeading: model.state == SessionState.FINISHED
            ? null
            : IconButton(
                icon: Icon(Icons.close),
                enableFeedback: false,
                splashRadius: 20,
                onPressed: () async {
                  if (model.state != SessionState.FINISHED &&
                      !await showConfirmDialog(
                          context, "You are about to quit this session"))
                    return;
                  Provider.of<GameSessionModel>(context, listen: false)
                      .quitQuiz();
                },
              ),

        automaticallyImplyLeading: false,

        // Points/next/finish button
        appbarActions: _appBarActions(context, model),

        child: Stack(
          children: [
                Column(
                  children: [
                    Center(
                      child: RaisedButton(
                        onPressed: startTimer,
                        child: Text('Begin'),
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                      ),
                    ),
                    Center(
                      child: RaisedButton(
                        onPressed: resetAnswer,
                        child: Text('Reset Answers'),
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            // spacer if question has no pic
                            if (!model.question.hasPicture) Spacer(),
                            // question text
                            Text("${model.question.text}",
                                style: Theme.of(context).textTheme.headline6),
                            // question picture or spacer if question has no pic
                            model.question.hasPicture
                                ? Expanded(
                                    child: FractionallySizedBox(
                                      widthFactor: 0.8,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 16.0),
                                        // Replace with Container when there's no picture
                                        child: FutureBuilder(
                                          future:
                                              Provider.of<QuizCollectionModel>(
                                                      context,
                                                      listen: false)
                                                  .getQuestionPicturePath(
                                                      model.question),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<String> snapshot) {
                                            if (!snapshot.hasData ||
                                                snapshot.data == null)
                                              return FractionallySizedBox(
                                                  widthFactor: 0.8,
                                                  heightFactor: 0.8,
                                                  child: Image(
                                                      image: AssetImage(
                                                          'assets/icon.png')));
                                            return Image.file(
                                                File(snapshot.data),
                                                fit: BoxFit.cover);
                                          },
                                        ),
                                      ),
                                    ),
                                  )
                                : Spacer(),

                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: TimerWidget(
                                  initTime: model.time,
                                  style: TextStyle(fontSize: 18)),
                            ),
                            if (model.questionHint != null)
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 4.0, bottom: 16.0),
                                child: Text(model.questionHint,
                                    style:
                                        Theme.of(context).textTheme.subtitle1),
                              )
                            else
                              Container(height: 16)
                          ],
                        ),
                      ),
                      // Answer selection boxes
                      //  Expanded(flex: 5, child: _quizAnswers(model))
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: top, left: left),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                    width: 40.0,
                    height: 40.0,
                  ),
                ),
              ] +
              tiltWidgets(model),
        ),
      ),
    );
  }

  /// Return the appropriate action/indicator (top right) for the user
  List<Widget> _appBarActions(BuildContext context, GameSessionModel model) => [
        if (model.state == SessionState.FINISHED &&
            model.role == GroupRole.OWNER)
          IconButton(
              onPressed: () => Navigator.of(context).popUntil(
                  (route) => !route.settings.name.startsWith('/session')),
              icon: Icon(Icons.flag))
        else if (model.state == SessionState.FINISHED)
          IconButton(
            onPressed: () =>
                Navigator.of(context).pushReplacementNamed('/session/finish'),
            icon: Icon(Icons.flag),
          )
        else if (model.state == SessionState.ANSWER &&
            model.role == GroupRole.OWNER)
          IconButton(
            onPressed: () => {model.showLeaderBoard(), resetAnswer(),pauseTimer()},
            icon: Icon(Icons.arrow_forward),
          )
        else if (model.state == SessionState.OUTCOME &&
            model.role == GroupRole.OWNER)
          IconButton(
            onPressed: () => model.nextQuestion(),
            icon: Icon(Icons.arrow_forward),
          )
        else if (model.state == SessionState.ANSWER &&
            model.session.quizType == QuizType.SELF_PACED &&
            model.session.type == GameSessionType.INDIVIDUAL)
          IconButton(
            onPressed: () => model.nextQuestion(),
            icon: Icon(Icons.arrow_forward),
          )
        else if (model.role == GroupRole.MEMBER)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '${model.points ?? 0}',
                  style: TextStyle(
                      color: Color(0xFFECC030),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Text("Points"),
              ],
            ),
          )
      ];

  void resetAnswer() {
    setState(() {
      noChosen = 0;
      chosen = [false, false, false, false];
    });
  }

  Widget positionedText4(String prompt) {
    return Positioned(
      child: Text(prompt),
      left: width - 55,
      top: height - 120,
    );
  }

  Widget positionedText3(String prompt) {
    return Positioned(
      child: Text(prompt),
      left: 0,
      top: height - 120,
    );
  }

  Widget positionedText2(String prompt) {
    return Positioned(
      child: Text(prompt),
      left: width - 55,
      top: 30,
    );
  }

  Widget positionedText1(String prompt) {
    return Positioned(
      child: Text(prompt),
      left: 0,
      top: 30,
    );
  }

  Widget fourCorners1() {
    return ClipPath(
      clipper: CustomClipperCorner1(),
      child: Container(
        color: chosen[0] ? Colors.green : null,
        height: height - appBarHeight,
        width: width,
      ),
    );
  }

  Widget fourCorners2() {
    return ClipPath(
      clipper: CustomClipperCorner2(),
      child: Container(
        color: chosen[1] ? Colors.green : null,
        height: height - appBarHeight,
        width: width,
      ),
    );
  }

  Widget fourCorners3() {
    return ClipPath(
      clipper: CustomClipperCorner3(),
      child: Container(
        color: chosen[2] ? Colors.green : null,
        height: height - appBarHeight,
        width: width,
      ),
    );
  }

  Widget fourCorners4() {
    return ClipPath(
      clipper: CustomClipperCorner4(),
      child: Container(
        color: chosen[3] ? Colors.green : null,
        height: height - appBarHeight,
        width: width,
      ),
    );
  }

  int noChosen = 0;

  void updateChosen(int i) {
    if (isMultipleChoice) {
      if (selectableAnswers > noChosen &&
          !chosen[i] &&
          Provider.of<GameSessionModel>(context, listen: false).state ==
              SessionState.QUESTION) {
        chosen[i] = true;
        noChosen++;
        Provider.of<GameSessionModel>(context, listen: false).toggleAnswer(i);
      }
    } else {
      if (chosen[0] == chosen[1]) {
        chosen[i] = true;
        trueOrFalse = chosen[0];
        Provider.of<GameSessionModel>(context, listen: false).toggleAnswer(i);
      }
    }
    return;
  }
}

import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors/sensors.dart';
import 'package:smart_broccoli/src/ui/shared/page.dart';
import 'package:smart_broccoli/src/ui/shared/tilt_graphics.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<bool> chosen = [false, false, false, false];

  int selectableAnswers = 1;
  int listOfAnswers = 4;

  double width;
  double height;

  double sizeOfTriangle;

  bool isMultipleChoice = true;
  bool isManyChoice = true;

  List<double> cord = [0.0, 0.0];

  // color of the circle
  Color color = Colors.greenAccent;

  // event returned from accelerometer stream
  AccelerometerEvent event;

  // hold a refernce to these, so that they can be disposed
  Timer timer;
  StreamSubscription accel;

  // positions and count
  double top = 125;
  double left;
  int count = 0;
  int selectAnswerTime = 0;

  setPosition(AccelerometerEvent event) {
    if (event == null) {
      return;
    }

    // print("x " + cord[0].toString());
    // print("y " + cord[1].toString());

    // print("x + " + event.x.toString());
    // print("y +" + event.y.toString());

    cord[0] = cord[0] - event.x*2;
    cord[1] = cord[1] + event.y*2;

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
    } else if (p1.distanceTo(p3) < sizeOfTriangle) {
      print("P3");
      selectAnswerTime++;
      if (selectAnswerTime > 10) {
        updateChosen(3);
        selectAnswerTime = 0;
      }
    } else if (p1.distanceTo(p4) < sizeOfTriangle) {
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
        if (count > 3) {
          pauseTimer();
        } else {
          // proccess the current event
          setPosition(event);
        }
      });
    }
  }

  pauseTimer() {
    // stop the timer and pause the accelerometer stream
    timer.cancel();
    accel.pause();

    // set the success color and reset the count
    setState(() {
      count = 0;
      color = Colors.green;
    });
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
    double offset = AppBar().preferredSize.height;

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

  @override
  Widget build(BuildContext context) {
    appBarHeight = MediaQuery.of(context).padding.top + kToolbarHeight;

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return CustomPage(
      title: "Test Title",
      child: Column(
        children: [
          Stack(
            children: [
              listOfAnswers == 4 ? [
              fourCorners1(),
              fourCorners2(),
              fourCorners3(),
              fourCorners4(),
              positionedText1("Option 1"),
              positionedText2("Option 2"),
              positionedText3("Option 3"),
              positionedText4("Option 4"),
              ] : Container(),
              listOfAnswers == 3 ? [
                fourCorners1(),
                fourCorners2(),
                fourCorners3(),
                positionedText1("Option 1"),
                positionedText2("Option 2"),
                positionedText3("Option 3"),
              ] : Container(),
              listOfAnswers == 2 ? [
                fourCorners1(),
                fourCorners2(),
                positionedText1("True"),
                positionedText2("False"),
              ] : Container(),
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
              Center(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    children: [
                      RaisedButton(
                        onPressed: startTimer,
                        child: Text('Begin'),
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                      ),
                      RaisedButton(
                        onPressed: resetAnswer,
                        child: Text('Reset Answers'),
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
      if (selectableAnswers > noChosen && !chosen[i]) {
        chosen[i] = true;
        noChosen++;
      }
    } else {
      if (chosen[0] == chosen[1]) {
        chosen[i] = true;
      }
    }
    return;
  }
}

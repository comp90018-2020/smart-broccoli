import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors/sensors.dart';
import 'package:smart_broccoli/src/ui/shared/tilt_graphics.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<bool> chosen = [false, false, false, false];

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

  setPosition(AccelerometerEvent event) {
    if (event == null) {
      return;
    }

    double offset = AppBar().preferredSize.height + 100;

    print("x " + cord[0].toString());
    print("y " + cord[1].toString());

    print("x + " + event.x.toString());
    print("y +" + event.y.toString());

    cord[0] = cord[0] + event.x / 7.0;
    cord[1] = cord[1] + event.y / 7.0;

    if (cord[0] >= width + 40) {
      cord[0] = width;
    }
    if (cord[0] <= 20) {
      cord[0] = 20;
    }
    if (cord[1] >= height - offset) {
      cord[1] = height - offset;
    }
    if (cord[1] <= 20) {
      cord[1] = 20;
    }

    print("Updated x " + cord[0].toString());
    print("Updated y " + cord[1].toString());

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
    Point p3 = Point(width, height);
    Point p4 = Point(0, height);
    Point p5 = Point(width, 0);

    if (p1.distanceTo(p2) < sizeOfTriangle) {
    } else if (p1.distanceTo(p3) < sizeOfTriangle) {
    } else if (p1.distanceTo(p4) < sizeOfTriangle) {
    } else if (p1.distanceTo(p5) < sizeOfTriangle) {
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
    cord[0] = width / 2.0 - 40;
    cord[1] = height / 2.0 - offset;
    top = cord[1];
    left = cord[0];

    if (width > height) {
      sizeOfTriangle = height / 4;
    } else {
      sizeOfTriangle = width / 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Stack(
            children: [
              fourCorners1(),
              fourCorners2(),
              fourCorners3(),
              fourCorners4(),
              Container(
                margin: EdgeInsets.only(top: top, left: left - 20),
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
    chosen = [false, false, false, false];
  }

  Widget tiltFalse() {
    return ClipPath(
      clipper: CustomClipperCorner3(),
      child: Container(
        color: chosen[1] ? Colors.green : null,
        height: height - 105.2,
        width: width,
      ),
    );
  }

  Widget tiltTrue() {
    return ClipPath(
      clipper: CustomClipperCorner3(),
      child: Container(
        color: chosen[0] ? Colors.green : null,
        height: height - 105.2,
        width: width,
      ),
    );
  }

  Widget fourCorners1() {
    return ClipPath(
      clipper: CustomClipperCorner1(),
      child: Container(
        color: chosen[0] ? Colors.green : null,
        height: width / 4,
        width: width / 4,
      ),
    );
  }

  Widget fourCorners2() {
    return ClipPath(
      clipper: CustomClipperCorner2(),
      child: Container(
        color: chosen[1] ? Colors.green : null,
        height: width / 4,
        width: width,
      ),
    );
  }

  Widget fourCorners3() {
    return ClipPath(
      clipper: CustomClipperCorner3(),
      child: Container(
        color: chosen[2] ? Colors.green : null,
        height: height - 105.2,
        width: width,
      ),
    );
  }

  Widget fourCorners4() {
    return ClipPath(
      clipper: CustomClipperCorner4(),
      child: Container(
        color: chosen[3] ? Colors.green : null,
        height: height - 105.2,
        width: width,
      ),
    );
  }

  void updateChosen(int i) {
    if (isMultipleChoice) {
      if (isManyChoice) {
        chosen[i] = true;
      } else {
        for (var j = 0; j < chosen.length; j++) {
          if (chosen[j]) {
            return;
          }
        }
        chosen[i] = true;
      }
    } else {
      if (chosen[0] != chosen[1]) {
        chosen[i] = true;
      }
    }
    return;
  }
}

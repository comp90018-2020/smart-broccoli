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
import 'package:smart_broccoli/theme.dart';

class TiltQuestion extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<TiltQuestion> {
  //creating Key for red panel
  GlobalKey areaLimit = GlobalKey();
  List<GlobalKey> globalKeyList = [
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey()
  ];

  List<bool> chosen = [false, false, false, false];

  double widthLimit;
  double heightLimit;

  double widthStart;
  double heightStart;

  bool canSelect = false;

  // 0 for t/f, 1 for MC with 4, 2 for MC with 3 choices
  int type;

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
  int count = 0;

  setPosition(AccelerometerEvent event) {
    if (event == null) {
      return;
    }

    if (cord[0] == 0.0 && cord[1] == 0.0) {
      final RenderBox renderBoxRed =
          areaLimit.currentContext.findRenderObject();
      final Offset offset = renderBoxRed.localToGlobal(Offset.zero);
      cord[0] = offset.dx;
      cord[1] = offset.dy;
      final Size size = renderBoxRed.size;
      heightLimit = size.height;
      widthLimit = size.width;
      heightStart = cord[1];
      widthStart = cord[0];
    }

    double nextCordx = cord[0] - event.x * 2;
    double nextCordy = cord[1] + event.y * 2;

    // print("x + " + event.x.toString());
    // print("y +" + event.y.toString());

    if (nextCordx >= widthLimit + widthStart - 40) {
      nextCordx = widthLimit + widthStart - 40;
    }
    if (nextCordx <= widthStart) {
      nextCordx = widthStart;
    }
    if (nextCordy >= heightLimit + heightStart - appBarHeight - 40) {
      nextCordy = heightLimit + heightStart - appBarHeight - 40;
    }
    if (nextCordy <= heightStart - appBarHeight) {
      nextCordy = heightStart - appBarHeight;
    }


    if ((cord[0] - nextCordx).abs() < 4 && (cord[1] - nextCordy).abs() < 4) {
      canSelect = true;
    } else {
      canSelect = false;
    }

    cord[0] = nextCordx;
    cord[1] = nextCordy;

    setState(() {
      left = cord[0];
    });

    // When y = 0 it should have a top position matching the target, which we set at 125
    setState(() {
      top = cord[1];
    });
  }

  selectGrid(GameSessionModel model) {

    Point<double> p1 = Point(cord[0], cord[1]);
    Point<double> p2 = Point(widthStart, heightStart - appBarHeight);
    Point<double> p3 = Point(widthStart, heightLimit + heightStart - appBarHeight);
    Point<double> p4 = Point(widthLimit + widthStart - 40, heightStart- appBarHeight);
    Point<double> p5 = Point(
        widthLimit + widthStart - 40, heightLimit + heightStart - appBarHeight);

    double d1 = p2.distanceTo(p1);
    double d2 = p4.distanceTo(p1);
    double d3 = p3.distanceTo(p1);
    double d4 = p5.distanceTo(p1);


    if (d1 <= d2 && d1 <= d3 && d1 <= d4) {
      if (model.question is TFQuestion) {
        model.toggleAnswer(1);
        print("Toggle True on Top left grid");
      } else {
        model.toggleAnswer(0);
        print("Toggle Top Left Grid MC 1");
      }
    } else if (d2 <= d1 && d2 <= d3 && d2 <= d4) {
      if (model.question is TFQuestion) {
        model.toggleAnswer(1);
        print("Toggle True on Top Right Grid");
      } else {
        model.toggleAnswer(1);
        print("Toggle Top Right Grid MC 2");
      }
    } else if (d3 <= d1 && d3 <= d2 && d3 <= d4) {
      if (model.question is TFQuestion) {
        model.toggleAnswer(0);
        print("Toggle False on Bottom Left Grid");
      } else {
        MCQuestion mcQuestion = model.question as MCQuestion;
        if (mcQuestion.options.length >= 3) {
          model.toggleAnswer(2);
          print("Toggle Bottom Left Grid MC 3");
        }
      }
    } else if (d4 <= d1 && d4 <= d2 && d4 <= d3) {
      if (model.question is TFQuestion) {
        model.toggleAnswer(0);
        print("Toggle False on Bottom Right Grid");
      } else {
        MCQuestion mcQuestion = model.question as MCQuestion;
        if (mcQuestion.options.length == 4) {
          model.toggleAnswer(3);
          print("Toggle Bottom Right Grid MC 4");
        }
        if (mcQuestion.options.length == 3) {
          model.toggleAnswer(2);
          print("Toggle Bottom Right Grid MC 4 ________");
        }
      }
    } else {}
  }

  startAccel(GameSessionModel model) {
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
        if (canSelect) selectGrid(model);
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
  void initState() {
    top = 0.0;
    left = 0.0;
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    super.initState();
  }

  _afterLayout(_) {}

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    print("Width " + MediaQuery.of(context).size.width.toString());
    print("Height" + MediaQuery.of(context).size.height.toString());
    appBarHeight = MediaQuery.of(context).padding.top + kToolbarHeight;
  }

  double appBarHeight;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return Consumer<GameSessionModel>(builder: (context, model, child) {
      if (model.question is MCQuestion) {
        if ((model.question as MCQuestion).options.length == 4) {
          type = 1;
        } else {
          type = 2;
        }
      } else {
        type = 0;
      }

      return CustomPage(
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  RaisedButton(
                    onPressed: startAccel(model),
                    child: Text('Begin'),
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                  ),
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
                                    padding: const EdgeInsets.only(top: 16.0),
                                    // Replace with Container when there's no picture
                                    child: FutureBuilder(
                                      future: Provider.of<QuizCollectionModel>(
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
                                        return Image.file(File(snapshot.data),
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
                            padding:
                                const EdgeInsets.only(top: 4.0, bottom: 16.0),
                            child: Text(model.questionHint,
                                style: Theme.of(context).textTheme.subtitle1),
                          )
                        else
                          Container(height: 16)
                      ],
                    ),
                  ),
                  Expanded(flex: 5, child: _quizAnswers(model)),
                  // Answer selection boxes
                ],
              ),
            ),

            // Ball
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
          ],
        ),
      );
    });
  }

// The answers grid, this is changed from Wireframe designs as this is much
// More flexiable than the previous offerings.
  Widget _quizAnswers(GameSessionModel model) {
    return Column(
      key: areaLimit,
      children: model.question is TFQuestion
          ? [
              Expanded(child: _answerTab(model, 1)),
              Expanded(child: _answerTab(model, 0))
            ]
          : [
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _answerTab(model, 0)),
                    Expanded(child: _answerTab(model, 1)),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    if ((model.question as MCQuestion).options.length > 2)
                      Expanded(child: _answerTab(model, 2)),
                    if ((model.question as MCQuestion).options.length > 3)
                      Expanded(child: _answerTab(model, 3)),
                  ],
                ),
              ),
            ],
    );
  }

// Answer selection tabs
  Widget _answerTab(GameSessionModel model, int index) {
    globalKeyList[index] = GlobalKey();

    return Card(
      key: globalKeyList[index],
      color: findColour(model, index),
      elevation: 4.0,
      child: InkWell(
        onTap: model.state == SessionState.QUESTION
            ? () => model.toggleAnswer(index)
            : null,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
            height: double.maxFinite,
            width: double.maxFinite,
            child: Center(
              child: model.question is TFQuestion
                  ? Text('${index == 0 ? 'False' : 'True'}',
                      style: TextStyle(fontSize: 36))
                  : Text(
                      (model.question as MCQuestion).options[index].text,
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ),
        ),
      ),
    );
  }

// Determines the correct colour to display
  Color findColour(GameSessionModel model, int index) {
    if (model.question is TFQuestion) {
      // correct answer
      if ([SessionState.ANSWER, SessionState.OUTCOME, SessionState.FINISHED]
              .contains(model.state) &&
          (model.correctAnswer.answer.tfSelection && index == 1 ||
              !model.correctAnswer.answer.tfSelection && index == 0))
        return AnswerColours.correct;
      // selected answer
      else if (model.answer.tfSelection != null &&
          (model.answer.tfSelection && index == 1 ||
              !model.answer.tfSelection && index == 0))
        return AnswerColours.selected;
    }
    // MC question
    else {
      // correct answer
      if ([SessionState.ANSWER, SessionState.OUTCOME, SessionState.FINISHED]
              .contains(model.state) &&
          model.correctAnswer.answer.mcSelection.contains(index))
        return AnswerColours.correct;
      // selected answer
      if (model.answer.mcSelection != null &&
          model.answer.mcSelection.contains(index))
        return model.answer.mcSelection.length ==
                (model.question as MCQuestion).numCorrect
            ? AnswerColours.selected
            : AnswerColours.pending;
    }
    // unselected answer
    return AnswerColours.normal;
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
            onPressed: () =>
                {model.showLeaderBoard(), resetAnswer(), pauseTimer()},
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
      chosen = [false, false, false, false];
    });
  }
}

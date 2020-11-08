import 'dart:async';
import 'dart:io';

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
  ///creating Key for red panel
  GlobalKey areaLimit = GlobalKey();

  /// Denotes if the Accelrometer is being used
  bool useAccel = false;

  /// Values used to determine the size of the Overall answer boxes
  double widthLimit;
  double heightLimit;

  double widthStart;
  double heightStart;

  bool ballRespawn;
  bool ballAnswered = false;

  int noAnswered = 0;

  /// Used to determine if the user's ball is so what stationary
  /// Therefore we can make selection
  bool canSelect = false;

  /// x and y coordinates of the ball should be all positive
  List<double> cord = [0.0, 0.0];

  /// event returned from accelerometer stream
  AccelerometerEvent event;

  /// hold a refernce to these, so that they can be disposed
  Timer timer;
  StreamSubscription accel;

  /// positions value of the ball for use in the main app
  double top;
  double left;

  /// Used to offset the pixels taken by the appbar
  double appBarHeight;

  setPosition(AccelerometerEvent event) {
    if (event == null) {
      return;
    }

    double xLimit, yLimit, yStart, xStart;

    /// First time initialisation
    /// TODO handle rotation changes if that happens
    if (left == 0.0 && top == 0.0) {
      final RenderBox renderBoxRed =
          areaLimit.currentContext.findRenderObject();
      if (renderBoxRed == null) {
        return;
      }
      final Offset offset = renderBoxRed.localToGlobal(Offset.zero);
      widthStart = offset.dx;
      heightStart = offset.dy;
      final Size size = renderBoxRed.size;
      heightLimit = size.height;
      widthLimit = size.width;
      cord[0] = widthStart + (widthLimit) / 2.0 - 20;
      cord[1] = heightStart - appBarHeight + (heightLimit) / 2.0 - 20;

      setState(() {
        left = cord[0];
      });

      setState(() {
        top = cord[1];
      });
      return;
    }

    /// The 40 number offset is to offset the size of the ball
    /// The width and height values may change so that's why they are
    /// put here
    xLimit = widthLimit + widthStart - 40;
    yLimit = heightLimit + heightStart - appBarHeight - 40;
    xStart = widthStart;
    yStart = heightStart - appBarHeight;

    /// We need to save the previous cord for now to see if there has been
    /// Significant changes
    double nextCordx = cord[0] - event.x;
    double nextCordy = cord[1] + event.y;

    /// Boundary checks width = x, height = y
    /// If the ball is out of the width limit
    if (nextCordx >= xLimit) {
      nextCordx = xLimit;
    }

    /// If the ball is below the width limit
    if (nextCordx <= xStart) {
      nextCordx = xStart;
    }

    /// If the ball is over the height limit
    if (nextCordy >= yLimit) {
      nextCordy = yLimit;
    }

    /// If the ball is over the starting height limit
    if (nextCordy <= yStart) {
      nextCordy = yStart;
    }

    /// The ball isn't moving too much, hence you can select an option
    if ((cord[0] - nextCordx).abs() < 4 && (cord[1] - nextCordy).abs() < 4) {
      canSelect = true;
    } else {
      canSelect = false;
    }

    /// After all checks complete, assign next cords
    cord[0] = nextCordx;
    cord[1] = nextCordy;

    // Set the state for x and y axis

    if (ballAnswered && ballRespawn) {
      ballAnswered = false;
      noAnswered++;
      cord[0] = xStart + (widthLimit) / 2.0 - 20;
      cord[1] = yStart + (heightLimit) / 2.0 - 20;
    } else if (ballAnswered && !ballRespawn) {
      cord[0] = xStart + (widthLimit) / 2.0 - 20;
      cord[1] = yStart + (heightLimit) / 2.0 - 20;
    }

    setState(() {
      left = cord[0];
    });

    setState(() {
      top = cord[1];
    });
  }

  /// Determine the grid to send off to the session model for processing
  selectGrid(GameSessionModel model) {
    /// limits as same as above
    double xLimit = widthLimit + widthStart - 40;
    double yLimit = heightLimit + heightStart - appBarHeight - 40;
    double xStart = widthStart;
    double yStart = heightStart - appBarHeight;

    double xLimitHalfWay = (widthLimit) / 2.0 + xStart;
    double yLimitHalfWay = (heightLimit) / 2.0 + yStart;

    List<bool> selected = [false, false, false, false];

    /// Ball is on the top side
    /// if ball is near the y start line and the xLimit line
    if (cord[1] <= yStart + 5 && cord[0] <= xLimit) {
      /// Determine on which side
      /// If it is A TF question
      if (model.question is TFQuestion) {
        //  print("TRUE/ TOP RIGHT and TOP LEFT");
        model.selectAnswer(1);
        ballAnswered = true;
        return;
      }

      /// If it is the top left grid that
      if (cord[0] <= xLimitHalfWay - 10) {
        selected[0] = true;
        //  print("Top Left");
      }

      /// If it is the top right grid
      else if (cord[0] >= xLimitHalfWay + 10) {
        selected[1] = true;
        //  print("Top Right");
      }

      /// If at center
      else {
        /// If True/False Question
        if (model.question is TFQuestion) {
          //   print("TRUE/ TOP RIGHT and TOP LEFT");
          model.selectAnswer(1);
          ballAnswered = true;
          return;
        }

        /// Otherwise ignore
      }
    }

    /// left side
    else if (cord[1] <= yLimit && cord[0] <= xStart + 5) {
      if (cord[1] <= yLimitHalfWay - 10) {
        /// CHeck if true false
        if (model.question is TFQuestion) {
          //   print("TRUE/ TOP RIGHT and TOP LEFT");
          model.selectAnswer(1);
          ballAnswered = true;
          return;
        }
        selected[0] = true;
        //   print("Top Left");
      } else if (cord[1] >= yLimitHalfWay + 10) {
        if (model.question is TFQuestion) {
          model.selectAnswer(0);
          //     print("FALSE/ BOTTOM RIGHT and BOTTOM LEFT");
          ballAnswered = true;
          return;
        } else {
          if ((model.question as MCQuestion).options.length == 3) {
            //      print("BOTTOM RIGHT and BOTTOM LEFT");
            model.selectAnswer(2);
            ballAnswered = true;
            return;
          }
        }

        selected[2] = true;
        //     print("Bottom Left");
      }

      /// No need for else statement as designs don't have any changes here
    }

    /// Bottom Side
    else if (cord[0] <= xLimit && cord[1] >= yLimit - 5) {
      /// We check if TF first
      if (model.question is TFQuestion) {
        model.selectAnswer(0);
        //    print("FALSE/ BOTTOM RIGHT and BOTTOM LEFT");
        ballAnswered = true;
        return;
      } else {
        if ((model.question as MCQuestion).options.length == 3) {
          //      print("BOTTOM RIGHT and BOTTOM LEFT");
          model.selectAnswer(2);
          ballAnswered = true;
          return;
        }
      }

      if (cord[0] <= xLimitHalfWay - 10) {
        selected[2] = true;
        //    print("Bottom Left");
      } else if (cord[0] >= xLimitHalfWay + 10) {
        selected[3] = true;
        //    print("Bottom Right");
      } else {
        /// If it somehow lands in the middle we do the following two checks
        if (model.question is TFQuestion) {
          model.selectAnswer(0);
          //      print("FALSE/ BOTTOM RIGHT and BOTTOM LEFT");
          ballAnswered = true;
          return;
        } else {
          if ((model.question as MCQuestion).options.length == 3) {
            //       print("BOTTOM RIGHT and BOTTOM LEFT");
            model.selectAnswer(2);
            ballAnswered = true;
            return;
          }
        }
      }
    }
    // Right Side
    else if (cord[0] >= xLimit - 5 && cord[1] <= yLimit) {
      /// If Top Right
      if (cord[1] <= yLimitHalfWay - 10) {
        /// If True/False Question
        if (model.question is TFQuestion) {
          //     print("TRUE/ TOP RIGHT and TOP LEFT");
          model.selectAnswer(1);
          ballAnswered = true;
          return;
        }

        //    print("Top Right");
        selected[1] = true;

        /// If Bottom Right
      } else if (cord[1] >= yLimitHalfWay + 10) {
        if (model.question is TFQuestion) {
          model.selectAnswer(0);
          //     print("FALSE/ BOTTOM RIGHT and BOTTOM LEFT");
          ballAnswered = true;
          return;
        } else {
          if ((model.question as MCQuestion).options.length == 3) {
            //    print("BOTTOM RIGHT and BOTTOM LEFT");
            model.selectAnswer(2);
            ballAnswered = true;
            return;
          }
        }
        //    print("Bottom Right");
        selected[3] = true;
      } else {}
    } else {}

    if (selected[0]) {
      model.selectAnswer(0);
      ballAnswered = true;
    } else if (selected[1]) {
      model.selectAnswer(1);
      ballAnswered = true;
    } else if (selected[2]) {
      model.selectAnswer(2);
      ballAnswered = true;
    } else if (selected[3]) {
      model.selectAnswer(3);
      ballAnswered = true;
    }
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

    // Accelerometer events may come faster than we need them so a timer is used to only proccess them every 50 milliseconds
    if (timer == null || !timer.isActive) {
      timer = Timer.periodic(Duration(milliseconds: 50), (_) {
        /// Set ball position
        setPosition(event);
        if (canSelect && model.role != GroupRole.OWNER) selectGrid(model);
      });
    }
  }

  pauseTimer() {
    ballAnswered = false;
    // stop the timer and pause the accelerometer stream
    if (timer != null) {
      timer.cancel();
    }
    if (accel != null) {
      accel.pause();
    }
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
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    appBarHeight = MediaQuery.of(context).padding.top + kToolbarHeight;
  }

  bool stopAnswer = false;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return Consumer<GameSessionModel>(builder: (context, model, child) {
      // Todo determine if it is much better to check SessionState.Question instead

      if (model.question is MCQuestion) {
        if ((model.question as MCQuestion).numCorrect == noAnswered) {
          stopAnswer = true;
        }

        if ((model.question as MCQuestion).numCorrect > 1) {
          ballRespawn = true;
        } else {
          ballRespawn = false;
        }
      } else {
        ballRespawn = false;
      }

      if (model.state != SessionState.QUESTION) {
        pauseTimer();
      } else {
        if (useAccel && model.role != GroupRole.OWNER) {
          startAccel(model);
        }
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
                  (!useAccel && model.role != GroupRole.OWNER)
                      ? RaisedButton(
                          child: Text('Ball Mode'),
                          onPressed: () => {
                            setState(() {
                              useAccel = true;
                            }),
                            startAccel(model)
                          },
                          color: Theme.of(context).primaryColor,
                          textColor: Colors.white,
                        )
                      : Container(),
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
            (useAccel &&
                    model.state == SessionState.QUESTION &&
                    !(ballAnswered && !ballRespawn) &&
                    !stopAnswer)
                ? Container(
                    margin: EdgeInsets.only(top: top, left: left),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                      width: 40.0,
                      height: 40.0,
                    ),
                  )
                : Container(),
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
    return Card(
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
            onPressed: () => {
              model.showLeaderBoard(),
              pauseTimer(),
              noAnswered = 0,
              stopAnswer = false,
            },
            icon: Icon(Icons.arrow_forward),
          )
        else if (model.state == SessionState.OUTCOME &&
            model.role == GroupRole.OWNER)
          IconButton(
            onPressed: () => {model.nextQuestion()},
            icon: Icon(Icons.arrow_forward),
          )
        else if (model.state == SessionState.ANSWER &&
            model.session.quizType == QuizType.SELF_PACED &&
            model.session.type == GameSessionType.INDIVIDUAL)
          IconButton(
            onPressed: () => {model.nextQuestion()},
            icon: Icon(Icons.arrow_forward),
          )
        else if (model.role == GroupRole.MEMBER)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
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
}

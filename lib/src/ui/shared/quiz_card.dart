import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui/shared/dialog.dart';
import 'package:smart_broccoli/theme.dart';
import 'package:smart_broccoli/src/ui/quiz_creator/quiz_creator.dart';

/// Represents a quiz card
class QuizCard extends StatefulWidget {
  final Quiz quiz;

  /// Aspect ratio
  final double aspectRatio;

  /// Whether options are enabled
  final bool optionsEnabled;

  QuizCard(this.quiz,
      {Key key, this.aspectRatio = 1.4, this.optionsEnabled = false});

  @override
  State<StatefulWidget> createState() => new _QuizCardState();
}

class _QuizCardState extends State<QuizCard> {
  @override
  Widget build(BuildContext context) => Card(
        elevation: 2,
        child: InkWell(
          onTap: () {},
          child: LayoutBuilder(
            builder: (context, constraints) {
              // If the height of the picture is less than 0.4 of the viewport
              // height, show it
              bool showPicture = constraints.maxWidth / widget.aspectRatio <
                  MediaQuery.of(context).size.height * 0.4;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Picture and title/group name
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quiz picture
                      showPicture
                          ? AspectRatio(
                              aspectRatio: widget.aspectRatio,
                              child: FutureBuilder(
                                future:
                                    Provider.of<QuizCollectionModel>(context)
                                        .getQuizPicture(widget.quiz.id),
                                builder: (BuildContext context,
                                    AsyncSnapshot<String> snapshot) {
                                  if (!snapshot.hasData ||
                                      snapshot.data == null)
                                    return FractionallySizedBox(
                                        widthFactor: 0.8,
                                        heightFactor: 0.8,
                                        child: Image(
                                            image:
                                                AssetImage('assets/icon.png')));
                                  return Image.file(File(snapshot.data),
                                      fit: BoxFit.cover);
                                },
                              ),
                            )
                          : SizedBox(),

                      // Quiz title & Group name
                      Container(
                        padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.quiz.title,
                              style: TextStyle(fontSize: 20),
                            ),
                            Text(
                              Provider.of<GroupRegistryModel>(context)
                                      .getGroup(widget.quiz.groupId)
                                      ?.name ??
                                  "Group ID: ${widget.quiz.groupId}",
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Space between

                  // Admin/quiz status
                  Column(
                    children: [
                      // Admin options
                      if (widget.quiz.role == GroupRole.OWNER) buildAdmin(),

                      // Quiz status
                      Container(
                        padding: EdgeInsets.fromLTRB(12, 8, 12, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            widget.quiz.type == QuizType.LIVE
                                ? liveIndicator()
                                : selfPacedIndicator(),
                            if (widget.quiz.complete)
                              Text(
                                'Complete',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      );

  // Smart quiz indicator
  Widget smartIndicator() => buildIndicator(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.5),
        child: Icon(
          Icons.circle,
          size: 12,
          color: Colors.brown,
        ),
      ),
      Text('Smart Live', style: TextStyle(fontSize: 13)));

  // Live indicator
  Widget liveIndicator() => buildIndicator(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.5),
        child: Icon(
          Icons.circle,
          size: 12,
          color: Theme.of(context).backgroundColor,
        ),
      ),
      Text('Live', style: TextStyle(fontSize: 13)));

  // Self-paced
  Widget selfPacedIndicator() => buildIndicator(
        Icon(
          Icons.schedule,
          size: 15,
          color: Theme.of(context).backgroundColor,
        ),
        Text('Self-paced', style: TextStyle(fontSize: 13)),
      );

  /// Builds indicator widget
  /// |icon|text|
  static Widget buildIndicator(Widget icon, Widget text) => Row(
        children: [
          icon,
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: text),
        ],
      );

  /// Build admin options row
  Widget buildAdmin() {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          widget.quiz.type == QuizType.LIVE
              // Activate live quiz
              ? Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 6),
                    child: widget.quiz.isActive
                        ? OutlineButton(
                            onPressed: null,
                            child: Text('Activated'),
                            padding: EdgeInsets.zero,
                            shape: SmartBroccoliTheme.raisedButtonShape,
                          )
                        : RaisedButton(
                            onPressed: () async {
                              if (!await _confirmActivateLiveQuiz()) return;
                              try {
                                Provider.of<QuizCollectionModel>(context,
                                        listen: false)
                                    .startQuizSession(widget.quiz,
                                        GameSessionType.INDIVIDUAL);
                              } catch (_) {
                                showErrorDialog(
                                    context, "Cannot start live session");
                              }
                            },
                            color: Theme.of(context).accentColor,
                            textColor:
                                Theme.of(context).colorScheme.onBackground,
                            child: Text('Activate'),
                            padding: EdgeInsets.zero,
                            shape: SmartBroccoliTheme.raisedButtonShape,
                          ),
                  ),
                )
              // Toggle activeness of self-paced quiz
              : Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Row(
                          children: [
                            Switch(
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                value: widget.quiz.isActive,
                                onChanged: (bool value) async {
                                  try {
                                    await Provider.of<QuizCollectionModel>(
                                            context,
                                            listen: false)
                                        .setQuizActivation(widget.quiz, value);
                                  } catch (_) {
                                    showErrorDialog(
                                        context, "Cannot update quiz status");
                                  }
                                }),
                            Container(
                                child: Text('Visible'),
                                transform: Matrix4.translationValues(-3, 0, 0))
                          ],
                        );
                      },
                    ),
                  ),
                ),
          // Settings
          MaterialButton(
            minWidth: 36,
            height: 36,
            color: Theme.of(context).accentColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onPressed: () {
              editQuiz(context, widget.quiz);
            },
            elevation: 2.0,
            child: Icon(
              Icons.settings,
              size: 20,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            shape: CircleBorder(),
          ),
        ],
      ),
    );
  }

  editQuiz(BuildContext context, Quiz quiz) async {
    // Navigator returns a Future that completes after calling
    dynamic result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizCreate(passedQuiz: quiz, groupId: widget.quiz.groupId),
      ),
    );
  }


  Future<bool> _confirmActivateLiveQuiz() async {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Confirm start session"),
        content: Text(
            "You are about to start a live session for the quiz: ${widget.quiz.title}"),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text("OK"),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}

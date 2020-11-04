import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/models/session_model.dart';
import 'package:smart_broccoli/src/ui/shared/dialog.dart';
import 'package:smart_broccoli/theme.dart';

/// Represents a quiz card
class QuizCard extends StatelessWidget {
  final Quiz quiz;

  /// Aspect ratio
  final double aspectRatio;

  /// Whether options are enabled
  final bool optionsEnabled;

  /// Whether to force no intrinsic height
  final bool alwaysShowPicture;

  QuizCard(this.quiz,
      {Key key,
      this.aspectRatio = 1.4,
      this.optionsEnabled = true,
      this.alwaysShowPicture = false});

  @override
  Widget build(BuildContext context) => Card(
        elevation: 2,
        child: InkWell(
          onTap: !optionsEnabled || quiz.role == GroupRole.OWNER
              ? null
              : () async {
                  if (quiz.type == QuizType.LIVE) {
                    try {
                      await Provider.of<GameSessionModel>(context,
                              listen: false)
                          .joinLiveSession(quiz);
                    } on SessionNotFoundException {
                      Scaffold.of(context).showSnackBar(
                        SnackBar(content: Text('Session no longer exists')),
                      );
                    } catch (_) {
                      Scaffold.of(context).showSnackBar(
                        SnackBar(content: Text('Something went wrong')),
                      );
                    }
                  } else {
                    Navigator.of(context)
                        .pushNamed("/session/start/quiz/${quiz.id}");
                  }
                },
          child: alwaysShowPicture
              // Always show picture
              ? _quizInner(context, true)
              : LayoutBuilder(
                  builder: (context, constraints) {
                    // If the height of the picture is less than 0.4 of the
                    // viewporp height, show it
                    bool showPicture = constraints.maxWidth / aspectRatio <
                        MediaQuery.of(context).size.height * 0.4;
                    return _quizInner(context, showPicture);
                  },
                ),
        ),
      );

  Widget _quizInner(BuildContext context, bool showPicture) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Picture and title/group name
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quiz picture
              if (showPicture)
                AspectRatio(
                  aspectRatio: aspectRatio,
                  child: FutureBuilder(
                    future: Provider.of<QuizCollectionModel>(context)
                        .getQuizPicturePath(quiz),
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (!snapshot.hasData || snapshot.data == null)
                        return FractionallySizedBox(
                            widthFactor: 0.8,
                            heightFactor: 0.8,
                            child: Image(image: AssetImage('assets/icon.png')));
                      return Image.file(File(snapshot.data), fit: BoxFit.cover);
                    },
                  ),
                ),

              // Quiz title & Group name
              Container(
                padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz.title,
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 4),
                    FutureBuilder(
                        future: Provider.of<GroupRegistryModel>(context)
                            .getGroup(quiz.groupId),
                        builder: (BuildContext context,
                            AsyncSnapshot<Group> snapshot) {
                          if (snapshot.hasData) {
                            return Text(snapshot.data.name,
                                style: TextStyle(fontSize: 15));
                          }
                          return Text('Loading',
                              style: TextStyle(fontSize: 15));
                        }),
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
              if (quiz.role == GroupRole.OWNER && optionsEnabled)
                buildAdmin(context),

              // Quiz status
              Container(
                padding: EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (quiz.type == QuizType.LIVE)
                      liveIndicator(context)
                    else if (quiz.type == QuizType.SELF_PACED)
                      selfPacedIndicator(context)
                    else if (quiz.type == QuizType.SMART_LIVE)
                      smartIndicator(),
                    if (quiz.complete)
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
          )
        ],
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
  Widget liveIndicator(BuildContext context) => buildIndicator(
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
  Widget selfPacedIndicator(BuildContext context) => buildIndicator(
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
  Widget buildAdmin(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          quiz.type == QuizType.LIVE
              // Activate live quiz
              ? Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 6),
                    child: quiz.isActive
                        ? OutlineButton(
                            onPressed: null,
                            child: Text('Activated'),
                            padding: EdgeInsets.zero,
                            shape: SmartBroccoliTheme.raisedButtonShape,
                          )
                        : RaisedButton(
                            onPressed: () async {
                              if (!await showConfirmDialog(
                                  context,
                                  "You are about to start a live session " +
                                      "for the quiz: ${quiz.title}",
                                  title: "Confirm start session",
                                  barrierDismissable: true)) return;
                              try {
                                Provider.of<GameSessionModel>(context,
                                        listen: false)
                                    .createSession(
                                        quiz.id, GameSessionType.INDIVIDUAL);
                              } catch (_) {
                                showBasicDialog(
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
                    child: Row(
                      children: [
                        Switch(
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            value: quiz.isActive,
                            onChanged: (bool value) async {
                              try {
                                await Provider.of<QuizCollectionModel>(context,
                                        listen: false)
                                    .setQuizActivation(quiz, value);
                              } catch (_) {
                                showBasicDialog(
                                    context, "Cannot update quiz status");
                              }
                            }),
                        Container(
                            child: Text('Visible'),
                            transform: Matrix4.translationValues(-3, 0, 0))
                      ],
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
              Navigator.of(context).pushNamed("/quiz/${quiz.id}");
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
}

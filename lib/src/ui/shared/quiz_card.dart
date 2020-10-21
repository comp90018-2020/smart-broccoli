import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui.dart';
import 'package:smart_broccoli/theme.dart';

/// Represents a quiz card
class QuizCard extends StatefulWidget {
  // TODO: change attributes to Group/Quiz
  /// Quiz name
  final String _quizName;

  // TODO: change attributes to Group/Quiz
  /// Group name
  final String _groupName;

  // Aspect ratio
  final double aspectRatio;

  /// Whether options are enabled
  final bool optionsEnabled;

  final Quiz _quiz;

  QuizCard(this._quizName, this._groupName, this._quiz,
      {Key key, this.aspectRatio = 1.4, this.optionsEnabled = false});

  @override
  State<StatefulWidget> createState() => new _QuizCardState();
}

class _QuizCardState extends State<QuizCard> {
  bool admin = true;
  QuizType quizType = QuizType.SELF_PACED;

  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          _startQuiz();
        },
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
                            child: Placeholder())
                        : SizedBox(),

                    // Quiz title & Group name
                    Container(
                      padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget._quizName,
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(widget._groupName,
                              style: TextStyle(fontSize: 15)),
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
                    buildAdmin(),

                    // Quiz status
                    Container(
                        padding: EdgeInsets.fromLTRB(12, 8, 12, 12),
                        width: double.maxFinite,
                        child: selfPacedIndicator())
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// TODO don't forget to de select quiz once the session is over.
  /// Known Issues: An null exception is thrown for a short time
  /// due to the time needed to select a quiz via the provider
  /// And also that this should only be used for debug purposes.
  /// In the real implementation this should also have a loading screen
  /// Which should wait for the provider to fetch the needed data
  /// Before continuing. It might be necessary to implement a loading screen Here
  void _startQuiz() {
    QuizCollectionModel qcm =
        Provider.of<QuizCollectionModel>(context, listen: false);
    qcm.selectQuiz(widget._quiz.id);
    // Navigator to session stuff here
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => QuizLobby()));
  }

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
    // Not admin, no box
    if (!admin) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          quizType == QuizType.LIVE
              // Activate live quiz
              ? Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: RaisedButton(
                      onPressed: () {},
                      color: Theme.of(context).accentColor,
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
                              value: true,
                              onChanged: (bool value) {},
                            ),
                            Container(
                                child: Text('Active'),
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
            onPressed: () {},
            elevation: 2.0,
            child: Icon(Icons.settings, size: 20),
            shape: CircleBorder(),
          ),
        ],
      ),
    );
  }
}

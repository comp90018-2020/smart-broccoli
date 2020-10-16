import 'package:flutter/material.dart';

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

  QuizCard(this._quizName, this._groupName,
      {Key key, this.aspectRatio = 1.4, this.optionsEnabled = false});

  @override
  State<StatefulWidget> createState() => new _QuizCardState();
}

class _QuizCardState extends State<QuizCard> {
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {},
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool showPicture = constraints.maxHeight > 175;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Quiz picture
                Column(children: [
                  showPicture
                      ? AspectRatio(
                          aspectRatio: widget.aspectRatio, child: Placeholder())
                      : SizedBox(),

                  // Quiz title & Group name
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                    width: double.maxFinite,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget._quizName,
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(widget._groupName, style: TextStyle(fontSize: 15)),
                      ],
                    ),
                  ),
                ]),

                // Quiz status
                Container(
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 10),
                    width: double.maxFinite,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Live', style: TextStyle(fontSize: 15)),
                      ],
                    )),
              ],
            );
          },
        ),
      ),
    );
  }
}

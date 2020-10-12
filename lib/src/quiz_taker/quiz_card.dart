import 'package:flutter/material.dart';

/// Represents a quiz card
class QuizCard extends StatefulWidget {
  /// Tap function
  final void Function() onTap;

  // TODO: change attributes to Group/Quiz
  /// Quiz name
  final String _quizName;

  /// Group name
  final String _groupName;

  // Aspect ratio
  final double aspectRatio;

  QuizCard(this._quizName, this._groupName,
      {Key key, this.onTap, this.aspectRatio = 1.4});

  @override
  State<StatefulWidget> createState() => new _QuizCardState();
}

class _QuizCardState extends State<QuizCard> {
  Widget build(BuildContext context) {
    return Card(
        elevation: 2,
        child: InkWell(
          onTap: widget.onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // Quiz picture
              AspectRatio(
                  aspectRatio: widget.aspectRatio, child: Placeholder()),

              // Rest should expand vertically
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(10),
                  width: double.maxFinite,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quiz title & Group name
                      Expanded(
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

                      // Quiz status
                      Text('Live', style: TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

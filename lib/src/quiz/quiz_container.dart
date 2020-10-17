import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'widgets/card.dart';

/// Build a list of quizzes
class QuizContainer extends StatefulWidget {
  QuizContainer(this.header, this.items, {Key key}) : super(key: key);

  /// List of items
  final List<String> items;

  /// Header widget
  final Widget header;

  @override
  State<StatefulWidget> createState() => new _BuildQuiz();
}

class _BuildQuiz extends State<QuizContainer> {
  _BuildQuiz();

  // Builder function for a list of card tiles
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: <Widget>[
            // Header widgets
            widget.header,

            // The list of quiz
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 300),
              child: Container(
                child: ListView.separated(
                  // Enable Horizontal Scroll
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    return Container(
                      constraints: BoxConstraints(maxWidth: 200, minWidth: 180),
                      margin: index == 0 || index == widget.items.length - 1
                          ? EdgeInsets.only(
                              left: index == 0 ? 20 : 0,
                              right: index == 0 ? 0 : 20)
                          : EdgeInsets.zero,
                      width: MediaQuery.of(context).size.height * 0.4,
                      child: QuizCard(
                        'Quiz name',
                        'Group name',
                      ),
                    );
                  },
                  // Space between the cards
                  separatorBuilder: (context, index) {
                    return Divider(indent: 1);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

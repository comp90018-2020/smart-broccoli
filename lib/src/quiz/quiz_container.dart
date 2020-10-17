import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'widgets/card.dart';

/// Build a list of quizzes
class QuizContainer extends StatefulWidget {
  QuizContainer(this.items,
      {Key key,
      this.header,
      this.padding = const EdgeInsets.only(top: 20, bottom: 8),
      this.hiddenButton = false})
      : super(key: key);

  /// List of items
  final List<String> items;

  /// Header widget
  final Widget header;

  /// Padding
  final EdgeInsetsGeometry padding;

  /// Whether to leave some space at the bottom
  final bool hiddenButton;

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
        padding: widget.padding,
        child: Column(
          children: <Widget>[
            // Header widgets
            widget.header != null ? widget.header : Container(),

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

            // Leave some space for a hidden floating action button
            widget.hiddenButton
                ? Visibility(
                    maintainState: true,
                    maintainAnimation: true,
                    maintainSize: true,
                    visible: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child:
                          FloatingActionButton(heroTag: null, onPressed: null),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}

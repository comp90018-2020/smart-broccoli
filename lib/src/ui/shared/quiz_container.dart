import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:smart_broccoli/src/data.dart';

import 'quiz_card.dart';

/// Build a list of quizzes
class QuizContainer extends StatefulWidget {
  QuizContainer(this.items,
      {Key key,
      this.header,
      this.padding = const EdgeInsets.only(top: 8, bottom: 8),
      this.headerPadding = const EdgeInsets.fromLTRB(8, 12, 8, 16),
      this.hiddenButton = false})
      : super(key: key);

  /// List of items
  final List<Quiz> items;

  /// Header widget
  final Widget header;

  /// Header padding
  final EdgeInsetsGeometry headerPadding;

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
            Padding(
              padding: widget.headerPadding,
              child: widget.header,
            ),

            // The list of quiz
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                // Minimum height, or will be height of longest child
                // if exceeding minimum height
                constraints: BoxConstraints(minHeight: 300),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: widget.items
                        .asMap()
                        .entries
                        .map((item) => Container(
                              constraints: BoxConstraints(maxWidth: 200),
                              margin: item.key == 0 ||
                                      item.key == widget.items.length - 1
                                  ? EdgeInsets.only(
                                      left: item.key == 0 ? 20 : 0,
                                      right: item.key == 0 ? 0 : 20)
                                  : EdgeInsets.zero,
                              width: MediaQuery.of(context).size.width * 0.4,
                              child:
                                  QuizCard(item.value, alwaysShowPicture: true),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),

            // Leave some space for a hidden floating action button
            if (widget.hiddenButton)
              Visibility(
                maintainState: true,
                maintainAnimation: true,
                maintainSize: true,
                visible: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: FloatingActionButton(heroTag: null, onPressed: null),
                ),
              )
          ],
        ),
      ),
    );
  }
}

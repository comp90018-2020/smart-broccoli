import 'package:flutter/material.dart';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/ui/shared/helper.dart';

import 'quiz_card.dart';

/// Build a list of quizzes
class QuizContainer extends StatefulWidget {
  QuizContainer(this.items,
      {Key key,
      this.header,
      this.padding = EdgeInsets.zero,
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                // Minimum height, or will be height of longest child
                // if exceeding minimum height
                constraints: BoxConstraints(minHeight: 300),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: mapIndexed(
                      widget.items,
                      ((index, item) => Container(
                            constraints: BoxConstraints(maxWidth: 200),
                            margin:
                                index == 0 || index == widget.items.length - 1
                                    ? EdgeInsets.only(
                                        left: index == 0 ? 20 : 0,
                                        right: index == 0 ? 0 : 20)
                                    : EdgeInsets.zero,
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: QuizCard(item, alwaysShowPicture: true),
                          )),
                    ).toList(),
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

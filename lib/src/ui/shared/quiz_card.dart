import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/theme.dart';

/// Represents a quiz card
class QuizCard extends StatefulWidget {
  final Quiz _quiz;

  /// Aspect ratio
  final double aspectRatio;

  /// Whether options are enabled
  final bool optionsEnabled;

  QuizCard(this._quiz,
      {Key key, this.aspectRatio = 1.4, this.optionsEnabled = false});

  @override
  State<StatefulWidget> createState() => new _QuizCardState();
}

class _QuizCardState extends State<QuizCard> {
  String title;
  String groupName;
  bool admin;
  QuizType quizType;

  Widget build(BuildContext context) {
    title = widget._quiz.title;
    groupName = Provider.of<GroupRegistryModel>(context)
            .getGroup(widget._quiz.groupId)
            ?.name ??
        "Group ID: ${widget._quiz.groupId}";
    admin = widget._quiz.role == GroupRole.OWNER;
    quizType = widget._quiz.type;

    return Card(
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
                            child: widget._quiz.picture == null
                                ? Placeholder()
                                : Image.memory(widget._quiz.picture,
                                    fit: BoxFit.cover),
                          )
                        : SizedBox(),

                    // Quiz title & Group name
                    Container(
                      padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: TextStyle(fontSize: 20)),
                          Text(groupName, style: TextStyle(fontSize: 15)),
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
                      child: quizType == QuizType.LIVE
                          ? liveIndicator()
                          : selfPacedIndicator(),
                    )
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
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

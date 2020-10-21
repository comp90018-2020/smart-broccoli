import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_broccoli/models.dart';
import 'package:smart_broccoli/src/session/lobby.dart';
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

  final Quiz quiz;



  QuizCard(this._quizName, this._groupName, this.quiz,
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
        onTap: () => _route(widget.quiz),
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool showPicture = constraints.maxHeight > 175;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Quiz picture
                showPicture
                    ? AspectRatio(
                        aspectRatio: widget.aspectRatio, child: Placeholder())
                    : SizedBox(),

                // Quiz title & Group name
                Expanded(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                    width: double.maxFinite,
                    height: double.maxFinite,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget._quizName,
                          style: TextStyle(fontSize: 15),
                        ),
                        Text(widget._groupName, style: TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                ),

                // Admin options
                buildAdmin(),

                // Quiz status
                Container(
                    padding: EdgeInsets.fromLTRB(12, 8, 12, 12),
                    width: double.maxFinite,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Auto quiz icon
                        // buildIndicator(
                        //     Padding(
                        //       padding:
                        //           const EdgeInsets.symmetric(horizontal: 1.5),
                        //       child: Icon(
                        //         Icons.circle,
                        //         size: 12,
                        //         color: Colors.brown,
                        //       ),
                        //     ),
                        //     Text('Smart Live', style: TextStyle(fontSize: 13))),
                        // Live icon
                        // buildIndicator(
                        //     Padding(
                        //       padding:
                        //           const EdgeInsets.symmetric(horizontal: 1.5),
                        //       child: Icon(
                        //         Icons.circle,
                        //         size: 12,
                        //         color: Theme.of(context).backgroundColor,
                        //       ),
                        //     ),
                        //     Text('Live', style: TextStyle(fontSize: 13))),
                        // Self-paced
                        buildIndicator(
                          Icon(
                            Icons.schedule,
                            size: 15,
                            color: Theme.of(context).backgroundColor,
                          ),
                          Text('Self-paced', style: TextStyle(fontSize: 13)),
                        )
                      ],
                    )),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Builds indicator widget
  /// |icon|text|
  Widget buildIndicator(Widget icon, Widget text) {
    return Row(
      children: [
        icon,
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0), child: text),
      ],
    );
  }

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
          // Activate
          quizType == QuizType.LIVE
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
              : Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Row(
                          children: [
                            Switch(
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
            child: Icon(
              Icons.settings,
            ),
            shape: CircleBorder(),
          ),
        ],
      ),
    );
  }

  void _route(Quiz _quiz){
    QuizCollectionModel qcm = Provider.of<QuizCollectionModel>(context, listen: true).init();
    UserProfileModel upm = Provider.of<UserProfileModel>(context, listen: true).init();
    qcm.selectQuiz(_quiz.id);

    Navigator.of(context).pushReplacement( MaterialPageRoute(builder: (context) => QuizLobby()));
  }
}

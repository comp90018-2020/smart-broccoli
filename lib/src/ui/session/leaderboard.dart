import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui/shared/page.dart';
import 'package:smart_broccoli/theme.dart';

/// Leaderboard page
class QuizLeaderboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Consumer<GameSessionModel>(
        builder: (context, model, child) => CustomPage(
          title: "Leaderboard",
          appbarActions: [
            if (model.role == GroupRole.OWNER ||
                model.state == SessionState.FINISHED)
              IconButton(
                onPressed: () => model.state == SessionState.FINISHED
                    ? Navigator.of(context).popUntil(
                        (route) => !route.settings.name.startsWith('/session'))
                    : model.nextQuestion(),
                icon: model.state == SessionState.FINISHED
                    ? Icon(Icons.flag)
                    : Icon(Icons.arrow_forward),
              )
          ],
          background: [
            // The clip for the current user's rank
            Consumer<GameSessionModel>(
              builder: (context, model, child) => Container(
                child: model.role == GroupRole.MEMBER
                    ? ClipPath(
                        clipper: _BackgroundRectClipper(),
                        child: Container(
                          color: Color(0xFFFEC12D),
                        ),
                      )
                    : Container(),
              ),
            ),
            // Overall wavy clip
            Container(
              child: ClipPath(
                clipper: _BackgroundClipper(),
                child: Container(
                  color: Theme.of(context).colorScheme.background,
                ),
              ),
            ),
          ],
          child: Column(
            children: <Widget>[
              // Top 3
              Container(
                  padding: EdgeInsets.all(16),
                  constraints: BoxConstraints(maxHeight: 165),
                  child: Consumer<GameSessionModel>(
                    builder: (context, model, child) => Wrap(
                      alignment: WrapAlignment.center,
                      runAlignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 25,
                      children: <Widget>[
                        if (model.outcome.leaderboard.length > 2)
                          _topThreeUsers(
                            context,
                            model.outcome.leaderboard[1].player.name,
                            50,
                            FutureBuilder(
                              future: model.getPeerProfilePicturePath(
                                  model.outcome.leaderboard[1].player.id),
                              builder: (BuildContext context,
                                      AsyncSnapshot<String> snapshot) =>
                                  UserAvatar(snapshot.data, maxRadius: 50),
                            ),
                          ),
                        if (model.outcome.leaderboard.length > 0)
                          _topThreeUsers(
                            context,
                            model.outcome.leaderboard[0].player.name,
                            75,
                            FutureBuilder(
                              future: model.getPeerProfilePicturePath(
                                  model.outcome.leaderboard[0].player.id),
                              builder: (BuildContext context,
                                      AsyncSnapshot<String> snapshot) =>
                                  UserAvatar(snapshot.data, maxRadius: 75),
                            ),
                            bold: true,
                          ),
                        if (model.outcome.leaderboard.length > 2)
                          _topThreeUsers(
                            context,
                            model.outcome.leaderboard[2].player.name,
                            50,
                            FutureBuilder(
                              future: model.getPeerProfilePicturePath(
                                  model.outcome.leaderboard[2].player.id),
                              builder: (BuildContext context,
                                      AsyncSnapshot<String> snapshot) =>
                                  UserAvatar(snapshot.data, maxRadius: 50),
                            ),
                          ),
                      ],
                    ),
                  )),

              // Current user & ranking
              Consumer<GameSessionModel>(
                builder: (context, model, child) => model.role ==
                        GroupRole.MEMBER
                    ? Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        height: 65,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                          child: Consumer<UserProfileModel>(
                            builder: (context, profile, child) => ListTile(
                              leading: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Rank

                                  Text(
                                    '${(model.outcome as OutcomeUser).record.newPos + 1}',
                                    style: SmartBroccoliTheme.listItemTextStyle,
                                  ),

                                  // Name/image
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24),
                                    child: Row(children: [
                                      // Profile image
                                      FutureBuilder(
                                        future: profile.getUserPicture(),
                                        builder: (BuildContext context,
                                                AsyncSnapshot<String>
                                                    snapshot) =>
                                            UserAvatar(snapshot.data,
                                                maxRadius: 20),
                                      ),
                                      // Name
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15),
                                        child: FutureBuilder(
                                          future: profile.getUser(),
                                          builder: (BuildContext context,
                                                  AsyncSnapshot<User>
                                                      snapshot) =>
                                              Text(
                                                  '${_nameFromSnapshot(snapshot)}',
                                                  style: SmartBroccoliTheme
                                                      .listItemTextStyle),
                                        ),
                                      ),
                                    ]),
                                  )
                                ],
                              ),
                              // Score
                              trailing: Wrap(
                                  spacing: 5,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                        '${(model.outcome as OutcomeUser).record.points}',
                                        style: SmartBroccoliTheme
                                            .listItemTextStyle),
                                    Icon(Icons.star, color: Color(0xFF656565))
                                  ]),
                            ),
                          ),
                        ),
                      )
                    : Container(height: 16),
              ),

              // List of users
              Expanded(
                child: Consumer<GameSessionModel>(
                  builder: (context, model, child) => _leaderboardList(model),
                ),
              ),
            ],
          ),
        ),
      );
}

String _nameFromSnapshot(AsyncSnapshot<User> snapshot) =>
    snapshot.hasData && snapshot.data != null
        ? snapshot.data.name + ' (you)'
        : 'You';

// Creates user image and name
Widget _topThreeUsers(
    BuildContext context, String text, double dimensions, Widget inner,
    {bool bold = false}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      // Bubble
      Container(
          height: dimensions,
          width: dimensions,
          decoration: WinnerBubble(),
          child: Align(alignment: Alignment.center, child: inner)),
      // Name
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal),
        ),
      ),
    ],
  );
}

Widget _leaderboardList(GameSessionModel model, {bool scrollable = true}) {
  return ListView.separated(
    shrinkWrap: true,
    itemCount: model.outcome.leaderboard.length,
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    physics: scrollable ? null : NeverScrollableScrollPhysics(),
    itemBuilder: (BuildContext context, int index) {
      return ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Rank
            Text(
              '${index + 1}',
              style: SmartBroccoliTheme.listItemTextStyle,
            ),
            // Name/image
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(children: [
                // Profile image
                FutureBuilder(
                  future: model.getPeerProfilePicturePath(
                      model.outcome.leaderboard[index].player.id),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) =>
                          UserAvatar(snapshot.data, maxRadius: 20),
                ),
                // Name
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(model.outcome.leaderboard[index].player.name,
                      style: SmartBroccoliTheme.listItemTextStyle),
                )
              ]),
            )
          ],
        ),
        // Score
        trailing: Wrap(
            spacing: 5,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('${model.outcome.leaderboard[index].record.points}',
                  style: SmartBroccoliTheme.listItemTextStyle),
              Icon(Icons.star, color: Color(0xFF656565))
            ]),
      );
    },
    separatorBuilder: (BuildContext context, int index) => const Divider(),
  );
}

// Curved clipper
class _BackgroundClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    path.lineTo(0, 125);
    var firstControlPoint = new Offset(size.width / 4, 160);
    var firstEndPoint = new Offset(size.width / 2, 145);
    var secondControlPoint = new Offset(size.width - (size.width / 4), 125);
    var secondEndPoint = new Offset(size.width, 150);

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height / 3);
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

// User highlight clipper
class _BackgroundRectClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    // Init width = 0, height = 0
    // GOTO width = 15 height = 0
    path.lineTo(15, 0);
    // GOTO width 15, height 165.0 + 30
    path.lineTo(15, 165.0 + 40);
    // Make a curve at control point width = 15, height = 165+30
    // i.e the Bottom leftmost point
    // Starting at width 15, height 165.0 + 30
    // And ending at width 20, 165.0+40
    path.quadraticBezierTo(15, 165.0 + 50, 25, 165.0 + 50);
    // From width 20, 165.0+40 goto Width = Width max - 20 height = 165.0+40
    path.lineTo(size.width - 25, 165.0 + 50);
    // Make a curve at control point width max - 15, height = 165+40
    // i.e the Bottom right most point
    // Starting at size.width - 20 , 165.0 + 40
    // And ending at  size.width - 15, 165.0 + 30
    path.quadraticBezierTo(
        size.width - 15, 165.0 + 50, size.width - 15, 165.0 + 40);
    // Finish up at the right top side
    path.lineTo(size.width - 15, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

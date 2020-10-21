import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
<<<<<<< HEAD:lib/src/ui/auth/init_page.dart
=======
import 'package:smart_broccoli/models.dart';
import 'package:smart_broccoli/src/quiz/manage_quiz.dart';
import 'package:smart_broccoli/src/quiz/take_quiz.dart';
>>>>>>> 3d15c5b... List of quizes should now be shown on all quiz related widgets, a issue with the .toJson function on quizzes is currently being investigated:lib/src/auth/init_page.dart

import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui/shared/page.dart';

class InitialRouter extends StatefulWidget {
  @override
  _InitialRouterState createState() => _InitialRouterState();
}

class _InitialRouterState extends State<InitialRouter> {
  @override
  Widget build(BuildContext context) {
    QuizCollectionModel qcm =
        Provider.of<QuizCollectionModel>(context, listen: true);
    qcm.init();
    qcm.refreshAvailableQuizzes();
    return Consumer<AuthStateModel>(
      builder: (context, state, child) {
        return CustomPage(
          title: 'Logged in',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: ListTile(
                  leading: Icon(Icons.info),
                  title: Text('This screen is just a placeholder'),
                ),
              ),
              Card(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Text('Token: ${state.token}'),
                ),
              ),
              RaisedButton(
                  onPressed: () => {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) => TakeQuiz()))
                      }),
              Spacer(),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                    child: Text('Logout'),
                    onPressed: state.logout,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

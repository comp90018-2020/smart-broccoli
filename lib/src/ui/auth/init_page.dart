import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui.dart';
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
    GroupRegistryModel grm =
        Provider.of<GroupRegistryModel>(context, listen: true);
    grm.refreshCreatedGroups();
    qcm.init();
    qcm.refreshAvailableQuizzes();
    qcm.refreshCreatedQuizzes();

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
                  child: Text("Test All Quiz"),
                  onPressed: () => {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) => TakeQuiz()))
                      }),
              RaisedButton(
                  child: Text("Test Group Quiz"),
                  onPressed: () => {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) => GroupMain()))
                      }),
              RaisedButton(
                  child: Text("Test Group Quiz"),
                  onPressed: () => {
                        tryCatch(),
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

  void tryCatch() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => ManageQuiz()));
  }
}

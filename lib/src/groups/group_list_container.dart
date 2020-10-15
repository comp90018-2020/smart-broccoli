import 'package:flutter/material.dart';

class GroupListContainer extends StatefulWidget {
  final String name;

  GroupListContainer({Key key, this.name}) : super(key: key);

  @override
  _GroupListContainerState createState() => _GroupListContainerState();
}

class _GroupListContainerState extends State<GroupListContainer> {
  final _groups = ["Math", "Biology", "Chemistry"];
  final _biggerFont = TextStyle(fontSize: 18.0);

  Widget build(BuildContext context) {
    if (widget.name == "created") {
      return Scaffold(
        appBar: AppBar(centerTitle: true),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            createAlertDialog(context).then((value) {
              if (value != null) {
                setState(() {
                  _groups.add(value);
                });
              }
            });

            // Add your onPressed code here!
          },
          label: Text('CREATE GROUP'),
          icon: Icon(Icons.group_add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: _buildSuggestions(),
      );
    } else {
      return Scaffold(
        appBar: AppBar(centerTitle: true),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            createAlertDialog(context).then((value) {
              if (value != null) {
                setState(() {
                  _groups.add(value);
                });
              }
            });

            // Add your onPressed code here!
          },
          label: Text('JOIN GROUP'),
          icon: Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: _buildSuggestions(),
      );
    }
  }

  Future<String> createAlertDialog(BuildContext context) {
    TextEditingController cController = TextEditingController();

    if (widget.name == "created") {
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Create New Group"),
              content: TextField(
                controller: cController,
                decoration: const InputDecoration(
                  labelText: 'Name for your group',
                ),
              ),
              actions: <Widget>[
                MaterialButton(
                    elevation: 5.0,
                    child: Text("Cancel"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
                MaterialButton(
                    elevation: 5.0,
                    child: Text("Create"),
                    onPressed: () {
                      Navigator.of(context).pop(cController.text.toString());
                    })
              ],
            );
          });
    } else {
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Join group"),
              content: TextField(
                controller: cController,
                decoration: const InputDecoration(
                  labelText: 'Name of the group',
                ),
              ),
              actions: <Widget>[
                MaterialButton(
                    elevation: 5.0,
                    child: Text("Cancel"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
                MaterialButton(
                    elevation: 5.0,
                    child: Text("Join"),
                    onPressed: () {
                      Navigator.of(context).pop(cController.text.toString());
                    })
              ],
            );
          });
    }
  }

  Widget _buildSuggestions() {
    return ListView.separated(
        itemCount: _groups.length,
        padding: EdgeInsets.all(16.0),
        itemBuilder: /*1*/ (context, i) {
          return _buildRow(_groups[i]);
        },
        separatorBuilder: (context, index) {
          return Divider();
        });
  }

  Widget _buildRow(String name) {
    return ListTile(
      title: Text(
        name,
        style: _biggerFont,
      ),
    );
  }
}

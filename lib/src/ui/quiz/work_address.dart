import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_broccoli/src/store/remote/location_api.dart';

///Address selection page
class MapSetting extends StatefulWidget {
  @override
  _MapSettingState createState() => new _MapSettingState();
}

List<LocationData> location = [];

class _MapSettingState extends State<MapSetting> {
  TextEditingController controller = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Work address'),
        centerTitle: true,
        elevation: 1.0,
      ),
      body: new Column(
        children: <Widget>[
          new Container(
            // color: Theme.of(context).primaryColor,
            child: new Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Card(
                child: new ListTile(
                  leading: new Icon(Icons.search),
                  title: new TextField(
                    controller: controller,
                    decoration: new InputDecoration(
                        hintText: 'Search', border: InputBorder.none),
                    textInputAction: TextInputAction.search,
                    onSubmitted: getLocations,
                  ),
                  trailing: new IconButton(
                    icon: new Icon(Icons.cancel_rounded),
                    onPressed: () {
                      controller.clear();
                      location.clear();
                      setState(() {});
                    },
                  ),
                ),
              ),
            ),
          ),
          new Expanded(
            child: location.length != 0 || controller.text.isNotEmpty
                ? new ListView.builder(
                    itemCount: location.length,
                    itemBuilder: (context, i) {
                      return new Card(
                        child: new ListTile(
                          title: new Text(location[i].name),
                        ),
                        margin: const EdgeInsets.all(0.0),
                      );
                    },
                  )
                : new ListView.builder(
                    itemCount: location.length,
                    itemBuilder: (context, index) {
                      return new Card(
                        child: new ListTile(
                          title: new Text(location[index].name),
                        ),
                        margin: const EdgeInsets.all(0.0),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  getLocations(String text) async {
    var _location = await LocationAPI.queryByName(text);
    setState(() {
      location = _location;
    });
  }
}

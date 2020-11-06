import 'package:flutter/material.dart';
import 'package:smart_broccoli/src/store/remote/location_api.dart';
import 'package:smart_broccoli/src/ui/shared/page.dart';

///Address selection page
class MapSetting extends StatefulWidget {
  @override
  _MapSettingState createState() => new _MapSettingState();
}

class _MapSettingState extends State<MapSetting> {
  TextEditingController searchTextController = new TextEditingController();

  List<LocationData> locationResults = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPage(
      title: "Notification setting",
      hasDrawer: false,
      child: new Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Card(
              child: new ListTile(
                leading: new Icon(Icons.search),
                title: new TextField(
                  controller: searchTextController,
                  decoration: new InputDecoration(
                      hintText: 'Search', border: InputBorder.none),
                  textInputAction: TextInputAction.search,
                  onSubmitted: getLocations,
                ),
                trailing: new IconButton(
                  icon: new Icon(
                    Icons.clear,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      searchTextController.clear();
                      locationResults.clear();
                    });
                  },
                ),
              ),
            ),
          ),
          new Expanded(
              child: new ListView.builder(
            itemCount: locationResults.length,
            itemBuilder: (context, i) {
              return new Card(
                child: new ListTile(
                  title: new Text(locationResults[i].name),
                  onTap: () {
                    Navigator.of(context).pop(locationResults[i].name);
                  },
                ),
                margin: const EdgeInsets.all(0.0),
              );
            },
          )),
        ],
      ),
    );
  }

  getLocations(String text) async {
    var _location = await LocationAPI.queryByName(text);
    setState(() {
      locationResults = _location;
    });
  }
}

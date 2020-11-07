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
  Widget build(BuildContext context) {
    return CustomPage(
      title: "Notification setting",
      hasDrawer: false,
      child: new Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Card(
              child: new TextField(
                controller: searchTextController,
                decoration: new InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.only(top: 14),
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search',
                  hintStyle: TextStyle(fontSize: 16.0),
                  border: InputBorder.none,
                  suffixIcon: new IconButton(
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
                textInputAction: TextInputAction.search,
                onSubmitted: getLocations,
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

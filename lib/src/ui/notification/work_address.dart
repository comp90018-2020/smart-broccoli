import 'package:flutter/material.dart';
import 'package:smart_broccoli/src/store/remote/location_api.dart';
import 'package:smart_broccoli/src/ui/shared/indicators.dart';
import 'package:smart_broccoli/src/ui/shared/page.dart';

///Address selection page
class MapSetting extends StatefulWidget {
  @override
  _MapSettingState createState() => new _MapSettingState();
}

class _MapSettingState extends State<MapSetting> {
  TextEditingController searchTextController = new TextEditingController();

  List<LocationData> _locationResults = [];

  @override
  Widget build(BuildContext context) {
    return CustomPage(
      title: "Notification setting",
      hasDrawer: false,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Builder(
                builder: (context) => TextField(
                  controller: searchTextController,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search',
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.clear,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          searchTextController.clear();
                          _locationResults.clear();
                        });
                      },
                    ),
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (text) => getLocations(context, text),
                ),
              ),
            ),
          ),
          Expanded(
              child: ListView.builder(
            itemCount: _locationResults.length,
            itemBuilder: (context, i) {
              return ListTile(
                title: Text(_locationResults[i].name),
                onTap: () {
                  Navigator.of(context).pop(_locationResults[i]);
                },
              );
            },
          )),
        ],
      ),
    );
  }

  getLocations(BuildContext context, String text) async {
    try {
      var _location = await LocationAPI.queryByName(text);
      setState(() {
        _locationResults = _location;
      });
    } catch (err) {
      return showErrSnackBar(
          context, "No valid results were found, please enter a valid address",
          dim: true);
    }
  }
}

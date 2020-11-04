import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:smart_broccoli/src/ui/shared/page.dart';
import 'package:flutter_settings/widgets/SettingsSection.dart';
import 'package:flutter_settings/widgets/SettingsIcon.dart';
import 'package:toast/toast.dart';
import 'package:flutter_settings/util/SettingsConstants.dart';
import 'package:flutter_settings/widgets/SettingsSelectionList.dart';
import 'package:flutter_settings/models/settings_list_item.dart';
import 'package:flutter_settings/widgets/SettingsCheckBox.dart';
import 'package:flutter_settings/widgets/SettingsInputField.dart';
import 'package:flutter_settings/widgets/SettingsSlider.dart';
import 'package:day_picker/day_picker.dart';

/// Smart quiz page
class SmartQuiz extends StatefulWidget {
  SmartQuiz({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SmartQuizState createState() => new _SmartQuizState();
}

class _SmartQuizState extends State<SmartQuiz> {
  WidgetDirection direction;
  var turnOffList;
  var numOfNotification;
  var wifiAtWork;
  var _caption = "After 15 seconds of inactivity";
  var _defaultNumOfNotification = "Unlimited";
  var _defaultWifiAtWork;
  var _selectionIndex = 0;
  var _workCaption = "Not set";
  var _wifiName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    turnOffList = new List<SettingsSelectionItem<int>>();
    turnOffList.add(SettingsSelectionItem<int>(0, "10 " + "minutes"));
    turnOffList.add(SettingsSelectionItem<int>(1, "30 " + "minutes"));
    turnOffList.add(SettingsSelectionItem<int>(2, "1 " + "hour"));
    turnOffList.add(SettingsSelectionItem<int>(3, "2 " + "hours"));
    turnOffList.add(SettingsSelectionItem<int>(4, "4 " + "hours"));
    turnOffList.add(SettingsSelectionItem<int>(5, "8 " + "hours"));
    _caption = "10 minutes";

    numOfNotification = new List<SettingsSelectionItem<int>>();
    numOfNotification.add(SettingsSelectionItem<int>(0, "Unlimited"));
    numOfNotification
        .add(SettingsSelectionItem<int>(1, "20 notifications per day"));
    numOfNotification
        .add(SettingsSelectionItem<int>(2, "10 notifications per day"));
    numOfNotification
        .add(SettingsSelectionItem<int>(3, "5 notifications per day"));
    numOfNotification
        .add(SettingsSelectionItem<int>(4, "1 notifications per day"));
    numOfNotification.add(SettingsSelectionItem<int>(5, "Never"));
    _defaultNumOfNotification = "Unlimited";

    wifiAtWork = new List<SettingsSelectionItem<int>>();
    wifiAtWork.add(SettingsSelectionItem<int>(0, "wifi 1"));
    wifiAtWork.add(SettingsSelectionItem<int>(1, "wifi 2"));
    wifiAtWork.add(SettingsSelectionItem<int>(2, "wifi 3"));
    wifiAtWork.add(SettingsSelectionItem<int>(3, "Never"));
    _defaultWifiAtWork = "Not set";
  }

  @override
  Widget build(BuildContext context) {
    return CustomPage(
      title: "Smart Live Quiz",
      hasDrawer: true,
      child: ListView(children: <Widget>[
        SettingsSection(
          title: Text('General setting'),
          settingsChildren: [
            SettingsSelectionList<int>(
              items: turnOffList,
              chosenItemIndex: _selectionIndex,
              title: 'Minimum window between notifications',
              titleStyle: TextStyle(fontSize: 16),
              dismissTitle: 'Cancel',
              caption: _caption,
              icon: new SettingsIcon(
                icon: Icons.timer_off,
                color: Colors.blue,
              ),
              onSelect: (value, index) {
                Toast.show(
                    "You have selected " + value.text.toString(), context);
                setState(() {
                  _selectionIndex = index;
                  _caption = value.text;
                });
              },
              context: context,
            ),
            SettingsSelectionList<int>(
              items: numOfNotification,
              chosenItemIndex: _selectionIndex,
              title: 'Max number of notifications per day',
              titleStyle: TextStyle(fontSize: 16),
              dismissTitle: 'Cancel',
              caption: _defaultNumOfNotification,
              icon: new SettingsIcon(
                icon: Icons.add_alert,
                color: Colors.green,
              ),
              onSelect: (value, index) {
                Toast.show(
                    "You have selected " + value.text.toString(), context);
                setState(() {
                  _selectionIndex = index;
                  _defaultNumOfNotification = value.text;
                });
              },
              context: context,
            ),
          ],
        ),
        Divider(height: 10, color: Colors.white),
        SettingsSection(
            title: Text(
              'When there my calendar is not free',
            ),
            settingsChildren: [
              SettingsCheckBox(
                title: 'Allow notifications for live quiz',
                titleStyle: TextStyle(fontSize: 16),
                icon: new SettingsIcon(
                  icon: Icons.live_tv,
                  color: Colors.blueAccent,
                ),
                onPressed: (bool value) {
                  Toast.show(
                      "Allow notifications for live quiz is " +
                          value.toString(),
                      context);
                },
                value: true,
                type: CheckBoxWidgetType.Switch,
              ),
              SettingsCheckBox(
                title: 'Allow notifications for smart quiz',
                titleStyle: TextStyle(fontSize: 16),
                icon: new SettingsIcon(
                  icon: Icons.lightbulb_outline,
                  color: Colors.orange,
                ),
                onPressed: (bool value) {
                  Toast.show(
                      "Allow notifications for smart quiz is " +
                          value.toString(),
                      context);
                },
                value: false,
                type: CheckBoxWidgetType.Switch,
              ),
            ]),
        Divider(height: 10, color: Colors.white),
        SettingsSection(
          title: Text(
            'Days of week',
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: SelectWeekDays(
            padding: 0,
            border: false,
            daysBorderColor: Colors.white,
            selectedDayTextColor: Colors.black54,
            boxDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(45.0),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                // colors: [const Color(0xFFE55CE4), const Color(0xFFBB75FB)],
                colors: [const Color(0xFFFEC12D), const Color(0xFFFEC12D)],
                tileMode:
                    TileMode.repeated, // repeats the gradient over the canvas
              ),
            ),
            onSelect: (values) {
              // <== Callback to handle the selected days
              print(values);
            },
          ),
        ),
        Divider(height: 10, color: Colors.white),
        SettingsSection(
            title: Text(
              'Self-paced quiz setting',
            ),
            settingsChildren: [
              SettingsCheckBox(
                title: 'Send notification when commuting',
                titleStyle: TextStyle(fontSize: 16),
                icon: new SettingsIcon(
                  icon: Icons.directions_walk,
                  color: Colors.red,
                ),
                onPressed: (bool value) {
                  Toast.show(
                      "Allow notifications on commuting is " + value.toString(),
                      context);
                },
                value: true,
                type: CheckBoxWidgetType.Switch,
              ),
            ]),
        Divider(height: 10, color: Colors.white),
        SettingsSection(
            title: Text(
              'When at work place',
            ),
            settingsChildren: [
              SettingsSelectionList<int>(
                items: wifiAtWork,
                chosenItemIndex: _selectionIndex,
                title: 'Wifi at work place',
                titleStyle: TextStyle(fontSize: 16),
                dismissTitle: 'Cancel',
                caption: _caption,
                icon: new SettingsIcon(
                  icon: Icons.wifi,
                  color: Colors.green,
                ),
                onSelect: (value, index) {
                  Toast.show(
                      "You have selected " + value.text.toString(), context);
                  setState(() {
                    _selectionIndex = index;
                    _caption = value.text;
                  });
                },
                context: context,
              ),
              SettingsInputField(
                dialogButtonText: 'Done',
                title: ('Edit Working address'),
                // titleStyle: TextStyle(fontSize: 16),
                icon: new SettingsIcon(
                  icon: Icons.location_on_outlined,
                  color: Colors.blue,
                ),
                caption: _workCaption,
                onPressed: (value) {
                  if (value.toString().isNotEmpty) {
                    Toast.show("You have Entered " + value, context);
                    setState(() {
                      _workCaption = value;
                    });
                  }
                },
                context: context,
              ),
              SettingsSlider(
                value: 0.5,
                activeColor: Colors.blue,
                icon: new SettingsIcon(
                  icon: Icons.track_changes,
                  color: Colors.red,
                  text: 'Radius',
                ),
                onChange: (value) {
                  Toast.show(
                      "Radius centered from work place: " +
                          (value * 10).round().toString() +
                          "km",
                      context);
                },
              ),
            ]),
        Divider(height: 10, color: Colors.white),
      ]),
    );
  }
}
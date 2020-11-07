import 'package:flutter/material.dart';
import 'package:flutter_settings/widgets/SettingsSection.dart';
import 'package:flutter_settings/widgets/SettingsIcon.dart';
import 'package:flutter_settings/util/SettingsConstants.dart';
import 'package:flutter_settings/widgets/SettingsSelectionList.dart';
import 'package:flutter_settings/models/settings_list_item.dart';
import 'package:flutter_settings/widgets/SettingsCheckBox.dart';
import 'package:flutter_settings/widgets/SettingsInputField.dart';
import 'package:flutter_settings/widgets/SettingsSlider.dart';
import 'package:flutter_settings/widgets/SettingsNavigatorButton.dart';
import 'package:toast/toast.dart';
import 'package:day_picker/day_picker.dart';
import 'package:smart_broccoli/src/ui/shared/page.dart';

/// Smart quiz page
class NotificationSetting extends StatefulWidget {
  NotificationSetting({Key key}) : super(key: key);

  @override
  _NotificationSettingState createState() => new _NotificationSettingState();
}

class _NotificationSettingState extends State<NotificationSetting> {
  WidgetDirection direction;
  List<SettingsSelectionItem<int>> turnOffList = [
    SettingsSelectionItem<int>(0, "Unlimited"),
    SettingsSelectionItem<int>(10, "10 minutes"),
    SettingsSelectionItem<int>(30, "30 minutes"),
    SettingsSelectionItem<int>(60, "1 hour"),
    SettingsSelectionItem<int>(120, "2 hours"),
    SettingsSelectionItem<int>(240, "4 hours"),
    SettingsSelectionItem<int>(480, "8 hours"),
  ];
  List<SettingsSelectionItem<int>> numOfNotification = [
    SettingsSelectionItem<int>(100, "Unlimited"),
    SettingsSelectionItem<int>(20, "20 notifications per day"),
    SettingsSelectionItem<int>(10, "10 notifications per day"),
    SettingsSelectionItem<int>(5, "5 notifications per day"),
    SettingsSelectionItem<int>(1, "1 notifications per day"),
    SettingsSelectionItem<int>(0, "Never"),
  ];
  var _winIndex = 0;
  var _numIndex = 0;
  List<bool> _weekDays = [false, false, false, false, false, false, false];
  var _liveQuizCalendar = true;
  var _smartQuizCalendar = false;
  var _smartDetection = true;
  var _wifiCaption = "Not set";
  var _workCaption = "Not set";
  var _radius = 0.5;
  var _commuting = true;

  @override
  Widget build(BuildContext context) {
    return CustomPage(
      title: "Notification setting",
      hasDrawer: true,
      child: ListView(children: <Widget>[
        SettingsSection(
          title: Text('General settings'),
          settingsChildren: [
            SettingsSelectionList<int>(
              items: turnOffList,
              //default selected item index, it will be the first item by default.
              chosenItemIndex: _winIndex,
              title: 'Minimum window between notifications',
              titleStyle: TextStyle(fontSize: 16),
              dismissTitle: 'Cancel',
              caption: turnOffList[_winIndex].text,
              icon: new SettingsIcon(
                icon: Icons.timer_off,
                color: Colors.blue,
              ),
              onSelect: (value, index) {
                setState(() => _winIndex = index);
              },
              context: context,
            ),
            SettingsSelectionList<int>(
              items: numOfNotification,
              //default selected item index, it will be the first item by default.
              chosenItemIndex: _numIndex,
              title: 'Max number of notifications per day',
              titleStyle: TextStyle(fontSize: 16),
              dismissTitle: 'Cancel',
              caption: numOfNotification[_numIndex].text,
              icon: new SettingsIcon(
                icon: Icons.add_alert,
                color: Colors.green,
              ),
              onSelect: (value, index) {
                setState(() => _numIndex = index);
              },
              context: context,
            ),
          ],
        ),
        Divider(height: 8, color: Colors.white),
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
                colors: [const Color(0xFFFEC12D), const Color(0xFFFEC12D)],
                tileMode:
                    TileMode.repeated, // repeats the gradient over the canvas
              ),
            ),
            onSelect: (List<String> values) {
              print(values);
              setState(() {
                if (values.contains("Sunday"))
                  _weekDays[0] = true;
                else
                  _weekDays[0] = false;
                if (values.contains("Monday"))
                  _weekDays[1] = true;
                else
                  _weekDays[1] = false;
                if (values.contains("Tuesday"))
                  _weekDays[2] = true;
                else
                  _weekDays[2] = false;
                if (values.contains("Wednesday"))
                  _weekDays[3] = true;
                else
                  _weekDays[3] = false;
                if (values.contains("Thursday"))
                  _weekDays[4] = true;
                else
                  _weekDays[4] = false;
                if (values.contains("Friday"))
                  _weekDays[5] = true;
                else
                  _weekDays[5] = false;
                if (values.contains("Saturday"))
                  _weekDays[6] = true;
                else
                  _weekDays[6] = false;
                print(_weekDays);
              });
            },
          ),
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
                  setState(() {
                    _liveQuizCalendar = value;
                  });
                },
                value: _liveQuizCalendar,
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
                  setState(() {
                    _smartQuizCalendar = value;
                  });
                },
                value: _smartQuizCalendar,
                type: CheckBoxWidgetType.Switch,
              ),
            ]),
        Divider(height: 10, color: Colors.white),
        SettingsSection(
            title: Text(
              'Don\'t notify me at work',
            ),
            settingsChildren: [
              SettingsCheckBox(
                title: 'Smart detection',
                titleStyle: TextStyle(fontSize: 16),
                icon: new SettingsIcon(
                  icon: Icons.auto_awesome_mosaic,
                  color: Colors.green,
                ),
                onPressed: (bool value) {
                  setState(() {
                    _smartDetection = value;
                  });
                },
                value: _smartDetection,
                type: CheckBoxWidgetType.Switch,
              ),
              SettingsInputField(
                titleStyle: TextStyle(fontSize: 16),
                dialogButtonText: 'Done',
                title: ('Wifi at work place'),
                icon: new SettingsIcon(
                  icon: Icons.wifi,
                  color: Colors.green,
                ),
                caption: _wifiCaption,
                onPressed: (value) {
                  if (value != null && value.isNotEmpty) {
                    setState(() {
                      _wifiCaption = value;
                    });
                  }
                },
                context: context,
              ),
              SettingsNavigatorButton(
                  title: 'Work address',
                  titleStyle: TextStyle(fontSize: 16),
                  icon: new SettingsIcon(
                    icon: Icons.location_on_outlined,
                    color: Colors.orange,
                  ),
                  context: context,
                  caption: _workCaption,
                  onPressed: () async {
                    var location =
                        await Navigator.of(context).pushNamed("/work_address");
                    if (location != null)
                      setState(() {
                        _workCaption = location;
                      });
                  }),
              SettingsSlider(
                value: _radius,
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
                  setState(() {
                    _radius = value;
                  });
                },
              ),
            ]),
        Divider(height: 10, color: Colors.white),
        SettingsSection(
            title: Text(
              'Self-paced quiz settings',
            ),
            settingsChildren: [
              SettingsCheckBox(
                title: 'Allow notification when commuting',
                titleStyle: TextStyle(fontSize: 16),
                icon: new SettingsIcon(
                  icon: Icons.directions_walk,
                  color: Colors.red,
                ),
                onPressed: (bool value) {
                  setState(() {
                    _commuting = value;
                  });
                },
                value: _commuting,
                type: CheckBoxWidgetType.Switch,
              ),
            ]),
        Divider(height: 5, color: Colors.white),
      ]),
    );
  }
}

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
class SmartQuiz extends StatefulWidget {
  SmartQuiz({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SmartQuizState createState() => new _SmartQuizState();
}

class _SmartQuizState extends State<SmartQuiz> {
  WidgetDirection direction;
  List<SettingsSelectionItem<int>> turnOffList = [
    SettingsSelectionItem<int>(0, "10 minutes"),
    SettingsSelectionItem<int>(1, "30 minutes"),
    SettingsSelectionItem<int>(2, "1 hour"),
    SettingsSelectionItem<int>(3, "2 hours"),
    SettingsSelectionItem<int>(4, "4 hours"),
    SettingsSelectionItem<int>(5, "8 hours"),
  ];
  String _caption = "10 minutes";
  List<SettingsSelectionItem<int>> numOfNotification = [
    SettingsSelectionItem<int>(0, "Unlimited"),
    SettingsSelectionItem<int>(1, "20 notifications per day"),
    SettingsSelectionItem<int>(2, "10 notifications per day"),
    SettingsSelectionItem<int>(3, "5 notifications per day"),
    SettingsSelectionItem<int>(4, "1 notifications per day"),
    SettingsSelectionItem<int>(4, "Never"),
  ];
  String _defaultNumOfNotification = "Unlimited";
  var _selectionIndex = 0;
  var _workCaption = "Not set";
  var _wifiCaption = "Not set";

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
                setState(() {
                  _selectionIndex = turnOffList[index].value;
                  // _caption = value.text;
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
                setState(() {
                  _selectionIndex = index;
                  _defaultNumOfNotification = value.text;
                });
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
                  Toast.show(
                      "Allow notifications on commuting is " + value.toString(),
                      context);
                },
                value: true,
                type: CheckBoxWidgetType.Switch,
              ),
              SettingsInputField(
                titleStyle: TextStyle(fontSize: 16),
                dialogButtonText: 'Done',
                title: ('Wifi at work place'),
                // titleStyle: TextStyle(fontSize: 16),
                icon: new SettingsIcon(
                  icon: Icons.wifi,
                  color: Colors.green,
                ),
                caption: _wifiCaption,
                onPressed: (value) {
                  if (value.toString().isNotEmpty) {
                    // Toast.show("You have Entered " + value, context);
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
                  //replace it with your widget which need to move on.
                  onPressed: () async {
                    var location =
                        await Navigator.of(context).pushNamed("work_address");
                    setState(() {
                      _workCaption = location;
                    });
                  }),
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
                  Toast.show(
                      "Allow notifications on commuting is " + value.toString(),
                      context);
                },
                value: true,
                type: CheckBoxWidgetType.Switch,
              ),
            ]),
        Divider(height: 5, color: Colors.white),
      ]),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_settings/widgets/SettingsIcon.dart';
import 'package:flutter_settings/util/SettingsConstants.dart';
import 'package:flutter_settings/widgets/SettingsSection.dart';
import 'package:flutter_settings/widgets/SettingsSelectionList.dart';
import 'package:flutter_settings/models/settings_list_item.dart';
import 'package:flutter_settings/widgets/SettingsCheckBox.dart';
import 'package:flutter_settings/widgets/SettingsInputField.dart';
import 'package:flutter_settings/widgets/SettingsSlider.dart';
import 'package:flutter_settings/widgets/SettingsNavigatorButton.dart';
import 'package:toast/toast.dart';
import 'package:selection_picker/selectionpicker.dart';
import 'package:selection_picker/selection_item.dart' as day;
import 'package:smart_broccoli/src/ui/shared/page.dart';

/// Smart quiz page
class NotificationSetting extends StatefulWidget {
  NotificationSetting({Key key}) : super(key: key);

  @override
  _NotificationSettingState createState() => new _NotificationSettingState();
}

class _NotificationSettingState extends State<NotificationSetting> {
  final List<SettingsSelectionItem<int>> _minWindowList = [
    SettingsSelectionItem<int>(0, "Unlimited"),
    SettingsSelectionItem<int>(10, "10 minutes"),
    SettingsSelectionItem<int>(30, "30 minutes"),
    SettingsSelectionItem<int>(60, "1 hour"),
    SettingsSelectionItem<int>(120, "2 hours"),
    SettingsSelectionItem<int>(240, "4 hours"),
    SettingsSelectionItem<int>(480, "8 hours"),
  ];
  final List<SettingsSelectionItem<int>> _maxNumberList = [
    SettingsSelectionItem<int>(0, "Unlimited"),
    SettingsSelectionItem<int>(20, "20 notifications per day"),
    SettingsSelectionItem<int>(10, "10 notifications per day"),
    SettingsSelectionItem<int>(5, "5 notifications per day"),
    SettingsSelectionItem<int>(1, "1 notifications per day"),
  ];
  var _minWindowIndex = 0;
  var _maxNumberIndex = 0;
  var _liveQuizCalendar = true;
  var _smartQuizCalendar = false;
  var _smartDetection = true;
  var _wifiCaption;
  var _workCaption;
  var _radius = 0.5;
  var _onMove = true;
  var _commuting = true;

  // isSelect is used to determine whether day is selected
  // on tap, isSelected is mutated
  List<day.SelectionItem> days = [
    day.SelectionItem(name: "MO", isSelected: true, identifier: 0),
    day.SelectionItem(name: "TU", isSelected: true, identifier: 1),
    day.SelectionItem(name: "WE", isSelected: false, identifier: 2),
    day.SelectionItem(name: "TH", isSelected: false, identifier: 3),
    day.SelectionItem(name: "FR", isSelected: false, identifier: 4),
    day.SelectionItem(name: "SA", isSelected: false, identifier: 5),
    day.SelectionItem(name: "SU", isSelected: false, identifier: 6)
  ];

  @override
  Widget build(BuildContext context) {
    return CustomPage(
      title: "Notification setting",
      hasDrawer: true,
      child: Container(
        child: ListView(children: <Widget>[
          SettingsSection(
            title: Text('General settings'),
            settingsChildren: [
              SettingsSelectionList<int>(
                items: _minWindowList,
                //default selected item index, it will be the first item by default.
                chosenItemIndex: _minWindowIndex,
                title: 'Minimum window between notifications',
                titleStyle: TextStyle(fontSize: 16),
                dismissTitle: 'Cancel',
                caption: _minWindowList[_minWindowIndex].text,
                icon: new SettingsIcon(
                  icon: Icons.timer_off,
                  color: Colors.blue,
                ),
                onSelect: (value, index) {
                  setState(() => _minWindowIndex = index);
                },
                context: context,
              ),
              SettingsSelectionList<int>(
                items: _maxNumberList,
                //default selected item index, it will be the first item by default.
                chosenItemIndex: _maxNumberIndex,
                title: 'Max number of notifications per day',
                titleStyle: TextStyle(fontSize: 16),
                dismissTitle: 'Cancel',
                caption: _maxNumberList[_maxNumberIndex].text,
                icon: new SettingsIcon(
                  icon: Icons.add_alert,
                  color: Colors.green,
                ),
                onSelect: (value, index) {
                  setState(() => _maxNumberIndex = index);
                },
                context: context,
              ),
            ],
          ),
          Divider(height: 8, color: Colors.white),
          SettingsSection(title: Text('Days of week')),

          //Days of week
          Container(
            height: 90,
            child: SelectionPicker(
              items: days,
              showSelectAll: false,
              showTitle: false,
              textColor: Colors.black54,
              backgroundColorNoSelected: Colors.grey[200],
              backgroundColorSelected: Color(0xFFFEC12D),
              onSelected: (List<day.SelectionItem> items) {
                print(days.map((e) => e.isSelected));
              },
              aligment: Alignment.center,
            ),
          ),
          Divider(height: 10, color: Colors.white),

          //Calendar
          SettingsSection(
              title: Text('When there my calendar is not free'),
              settingsChildren: [
                //Calendar for live quiz
                SettingsCheckBox(
                  title: 'Allow notifications for live quiz',
                  titleStyle: TextStyle(fontSize: 16),
                  icon: new SettingsIcon(
                    icon: Icons.live_tv,
                    color: Colors.blueAccent,
                  ),
                  onPressed: (bool value) {
                    setState(() => _liveQuizCalendar = value);
                  },
                  value: _liveQuizCalendar,
                  type: CheckBoxWidgetType.Switch,
                ),

                //Calendar for smart quiz
                SettingsCheckBox(
                  title: 'Allow notifications for smart quiz',
                  titleStyle: TextStyle(fontSize: 16),
                  icon: new SettingsIcon(
                    icon: Icons.lightbulb_outline,
                    color: Colors.orange,
                  ),
                  onPressed: (bool value) {
                    setState(() => _smartQuizCalendar = value);
                  },
                  value: _smartQuizCalendar,
                  type: CheckBoxWidgetType.Switch,
                ),
              ]),
          Divider(height: 10, color: Colors.white),

          //Work setting
          SettingsSection(
              title: Text('Don\'t notify me at work'),
              settingsChildren: [
                //Smart detection
                SettingsCheckBox(
                  title: 'Smart detection',
                  titleStyle: TextStyle(fontSize: 16),
                  icon: new SettingsIcon(
                    icon: Icons.auto_awesome_mosaic,
                    color: Colors.green,
                  ),
                  onPressed: (bool value) {
                    setState(() => _smartDetection = value);
                  },
                  value: _smartDetection,
                  type: CheckBoxWidgetType.Switch,
                ),

                //wifi setting
                SettingsInputField(
                  titleStyle: TextStyle(fontSize: 16),
                  dialogButtonText: 'Done',
                  title: ('Wifi at work place'),
                  icon: new SettingsIcon(
                    icon: Icons.wifi,
                    color: Colors.green,
                  ),
                  caption: _wifiCaption == null ? "Not set" : _wifiCaption,
                  onPressed: (value) {
                    if (value != null && value.isNotEmpty) {
                      setState(() => _wifiCaption = value);
                    }
                  },
                  context: context,
                ),

                // Address setting
                SettingsNavigatorButton(
                    title: 'Work address',
                    titleStyle: TextStyle(fontSize: 16),
                    icon: new SettingsIcon(
                      icon: Icons.location_on_outlined,
                      color: Colors.orange,
                    ),
                    context: context,
                    caption: _workCaption == null ? "Not set" : _workCaption,
                    onPressed: () async {
                      var location = await Navigator.of(context)
                          .pushNamed("/work_address");
                      if (location != null)
                        setState(() => _workCaption = location);
                    }),

                // Radius setting
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
                        "Radius centered from work place: ${(value * 10).round().toString()} km",
                        context);
                    setState(() => _radius = value);
                  },
                ),
              ]),
          Divider(height: 10, color: Colors.white),

          //Move settings
          SettingsSection(title: Text('When moving'), settingsChildren: [
            //Move switch

            // SettingsCheckBox(
            //   title: 'Allow notification on the move',
            //   titleStyle: TextStyle(fontSize: 16),
            //   icon: new SettingsIcon(
            //     icon: Icons.directions_walk,
            //     color: Colors.amber,
            //   ),
            //   onPressed: (bool value) {
            //     setState(() {
            //       _onMove = value;
            //       print(value);
            //       if (!value) _commuting = false;
            //       print(_commuting);
            //     });
            //   },
            //   value: _onMove,
            //   type: CheckBoxWidgetType.Switch,
            // ),

            // //Commute switch
            // SettingsCheckBox(
            //   title: 'Allow notification on commute',
            //   titleStyle: TextStyle(fontSize: 16),
            //   icon: new SettingsIcon(
            //     icon: Icons.train,
            //     color: Colors.blueAccent,
            //   ),
            //   disabled: _onMove == false,
            //   onPressed: (bool value) {
            //     setState(() => _commuting = value);
            //   },
            //   value: _commuting,
            //   type: CheckBoxWidgetType.Switch,
            // ),
          ]),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
            title: Row(children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Icon(Icons.directions_walk, color: Colors.amber),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  "Allow notifications on the move",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ]),
            onTap: () {
              setState(() {
                _onMove = !_onMove;
                if (!_onMove) _commuting = false;
              });
            },
            trailing: Switch(
                value: _onMove,
                onChanged: (bool value) {
                  setState(() {
                    _onMove = value;
                    if (!value) _commuting = false;
                  });
                }),
          ),
        ]),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:flutter_settings/widgets/Separator.dart';
import 'package:flutter_settings/widgets/SettingsIcon.dart';
import 'package:flutter_settings/widgets/SettingsSection.dart';
import 'package:flutter_settings/widgets/SettingsSelectionList.dart';
import 'package:flutter_settings/models/settings_list_item.dart';
import 'package:flutter_settings/widgets/SettingsInputField.dart';
import 'package:flutter_settings/widgets/SettingsSlider.dart';
import 'package:flutter_settings/widgets/SettingsNavigatorButton.dart';
import 'package:provider/provider.dart';
import 'package:smart_broccoli/src/data/prefs.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui/shared/dialog.dart';
import 'package:smart_broccoli/src/ui/shared/helper.dart';
import 'package:smart_broccoli/src/ui/shared/page.dart';
import 'package:smart_broccoli/src/ui/shared/indicators.dart';
import 'package:toast/toast.dart';
import 'package:selection_picker/selectionpicker.dart';
import 'package:selection_picker/selection_item.dart' as day;

/// Smart quiz page
class NotificationSetting extends StatefulWidget {
  NotificationSetting({Key key}) : super(key: key);

  @override
  _NotificationSettingState createState() => new _NotificationSettingState();
}

class _NotificationSettingState extends State<NotificationSetting> {
  static final List<SettingsSelectionItem<int>> _minWindowList = [
    SettingsSelectionItem<int>(0, "Unlimited"),
    SettingsSelectionItem<int>(10, "10 minutes"),
    SettingsSelectionItem<int>(30, "30 minutes"),
    SettingsSelectionItem<int>(60, "1 hour"),
    SettingsSelectionItem<int>(120, "2 hours"),
    SettingsSelectionItem<int>(240, "4 hours"),
    SettingsSelectionItem<int>(480, "8 hours"),
  ];
  static final List<SettingsSelectionItem<int>> _maxNumberList = [
    SettingsSelectionItem<int>(0, "Unlimited"),
    SettingsSelectionItem<int>(1, "1 notification per day"),
    SettingsSelectionItem<int>(5, "5 notifications per day"),
    SettingsSelectionItem<int>(20, "20 notifications per day"),
    SettingsSelectionItem<int>(10, "10 notifications per day"),
  ];

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

  double _radius = 0.5;

  // Copy of notification preferences
  NotificationPrefs _copy;

  // Saving?
  bool _committed = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<UserProfileModel>(context).getNotificationPrefs(),
      builder: (context, snapshot) {
        // Make a copy
        if (_copy == null && snapshot.hasData) {
          _copy = snapshot.data;
          // Set radius
          _radius = _copy.workRadius == null ? 0 : _copy.workRadius / 10;
          // Set days
          mapIndexed(_copy.dayPrefs.getPrefs(), (index, element) {
            days[index].isSelected = element;
          });
        }

        return WillPopScope(
          onWillPop: () async {
            if (snapshot.hasData && snapshot.data != _copy)
              return await showConfirmDialog(
                  context, "You have unsaved changes, exit?");
            return true;
          },
          child: CustomPage(
            title: "Notification Settings",
            hasDrawer: true,
            appbarActions: [
              // Show when modified
              if (_copy != null && snapshot.hasData && snapshot.data != _copy)
                Builder(
                  builder: (context) => IconButton(
                    icon: Icon(Icons.check),
                    padding: EdgeInsets.zero,
                    splashRadius: 20,
                    onPressed: _committed ? null : () => _save(context),
                  ),
                ),
            ],
            child: snapshot.hasError
                ? Center(
                    child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Cannot load settings"),
                  ))
                : !snapshot.hasData
                    ? LoadingIndicator(EdgeInsets.all(16))
                    : ListView(children: <Widget>[
                        SettingsSection(
                          title: Text('General settings'),
                          settingsChildren: [
                            // Minimum windows
                            SettingsSelectionList<int>(
                              items: _minWindowList,
                              chosenItemIndex: _map_1(_minWindowList.indexWhere(
                                  (element) =>
                                      element.value == _copy.minWindow)),
                              title: 'Minimum window between notifications',
                              titleStyle: TextStyle(fontSize: 16),
                              dismissTitle: 'Cancel',
                              caption: _minWindowList[_map_1(
                                      _minWindowList.indexWhere((element) =>
                                          element.value == _copy.minWindow))]
                                  .text,
                              icon: new SettingsIcon(
                                  icon: Icons.timer_off, color: Colors.blue),
                              onSelect: (value, index) {
                                setState(() => _copy.minWindow = value);
                              },
                              context: context,
                            ),

                            // Max number of notifications
                            SettingsSelectionList<int>(
                              items: _maxNumberList,
                              chosenItemIndex: _map_1(_maxNumberList.indexWhere(
                                  (element) =>
                                      element.value == _copy.maxPerDay)),
                              title: 'Max number of notifications per day',
                              titleStyle: TextStyle(fontSize: 16),
                              dismissTitle: 'Cancel',
                              caption: _maxNumberList[_map_1(
                                      _maxNumberList.indexWhere((element) =>
                                          element.value == _copy.maxPerDay))]
                                  .text,
                              icon: new SettingsIcon(
                                icon: Icons.add_alert,
                                color: Colors.green,
                              ),
                              onSelect: (value, index) {
                                setState(() => _copy.maxPerDay = value);
                              },
                              context: context,
                            ),
                          ],
                        ),
                        Divider(height: 4, color: Colors.white),

                        // Days of week
                        SettingsSection(title: Text('Days of week')),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          child: SelectionPicker(
                            items: days,
                            showSelectAll: false,
                            showTitle: false,
                            textColor: Colors.black54,
                            backgroundColorNoSelected: Colors.grey[200],
                            backgroundColorSelected: Color(0xFFFEC12D),
                            onSelected: (List<day.SelectionItem> items) {
                              _copy.dayPrefs.setPrefs(
                                  days.map((e) => e.isSelected).toList());
                            },
                            aligment: Alignment.center,
                          ),
                        ),
                        Divider(height: 4, color: Colors.white),

                        // Calendar
                        SettingsSection(
                          title: Text('When my calendar is not free'),
                        ),

                        // Calendar live quiz
                        _switchListTile(
                            icon: Icon(Icons.live_tv, color: Colors.blueAccent),
                            title: "Allow notifications for live quiz",
                            onTap: () {
                              setState(() => _copy.allowLiveIfCalendar =
                                  !_copy.allowLiveIfCalendar);
                            },
                            value: _copy.allowLiveIfCalendar,
                            disabled: false),
                        Separator(),

                        // Calendar smart quiz
                        _switchListTile(
                            icon: Icon(Icons.lightbulb_outline,
                                color: Colors.orange),
                            title: "Allow notifications for smart quiz",
                            onTap: () {
                              setState(() => _copy.allowSelfPacedIfCalendar =
                                  !_copy.allowSelfPacedIfCalendar);
                            },
                            value: _copy.allowSelfPacedIfCalendar,
                            disabled: false),
                        Divider(height: 4, color: Colors.white),

                        // Work setting
                        SettingsSection(
                          title: Text('Don\'t notify me at work'),
                        ),

                        // Smart detection
                        _switchListTile(
                            icon: Icon(Icons.auto_awesome_mosaic,
                                color: Colors.blueAccent),
                            title: "Smart detection",
                            onTap: () {
                              setState(
                                  () => _copy.workSmart = !_copy.workSmart);
                            },
                            value: _copy.workSmart,
                            disabled: false),

                        // Wifi setting
                        SettingsInputField(
                          titleStyle: TextStyle(fontSize: 16),
                          dialogButtonText: 'Done',
                          title: ('Wifi at work place'),
                          icon: new SettingsIcon(
                            icon: Icons.wifi,
                            color: Colors.green,
                          ),
                          caption: _copy.workSSID == null
                              ? "Not set"
                              : _copy.workSSID,
                          onPressed: (value) {
                            if (value != null && value.isNotEmpty) {
                              setState(() => _copy.workSSID = value);
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
                            caption: _copy.workLocation == null
                                ? "Not set"
                                : _copy.workLocation,
                            onPressed: () async {
                              var location = await Navigator.of(context)
                                  .pushNamed("/work_address");
                              if (location != null)
                                setState(() => _copy.workLocation = location);
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
                            _copy.workRadius = (value * 10).round();
                          },
                        ),
                        Divider(height: 6, color: Colors.white),

                        ///Move settings
                        SettingsSection(title: Text('When moving')),

                        /// Move
                        _switchListTile(
                            icon: Icon(Icons.directions_walk,
                                color: Colors.amber),
                            title: "Allow notifications on the move",
                            onTap: () {
                              setState(() {
                                _copy.allowOnTheMove = !_copy.allowOnTheMove;
                                _copy.allowOnCommute = _copy.allowOnTheMove;
                              });
                            },
                            value: _copy.allowOnTheMove),
                        Separator(),

                        /// Commute
                        _switchListTile(
                          icon: Icon(Icons.train, color: Colors.blueAccent),
                          title: "Allow notifications on commute",
                          onTap: () {
                            setState(() {
                              _copy.allowOnCommute = !_copy.allowOnCommute;
                            });
                          },
                          value: _copy.allowOnCommute,
                          disabled: !_copy.allowOnTheMove,
                        ),
                      ]),
          ),
        );
      },
    );
  }

  // Maps -1 to 0
  int _map_1(int index) => index == -1 ? 0 : index;

  // Save settings
  void _save(BuildContext context) async {
    setState(() => _committed = true);
    await context
        .read<UserProfileModel>()
        .setNotificationPrefs(_copy)
        .catchError((err) => showErrSnackBar(context, err.toString()));
    showSnackBar(context, "Settings saved");
    setState(() => _committed = false);
  }

  /// A switch list tile mimicking the ListTile provided by the package
  /// The package contained state interally, which we could not modify
  Widget _switchListTile(
      {@required Icon icon,
      @required String title,
      @required void Function() onTap,
      @required bool value,
      bool disabled = false}) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      title: Row(children: [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: icon,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ]),
      onTap: onTap,
      trailing: Switch(
          value: value,
          onChanged: disabled == true ? null : (value) => onTap()),
    );
  }
}

import 'package:collection/collection.dart';
import 'package:quiver/core.dart';
import 'package:smart_broccoli/src/remote.dart';

class NotificationPrefs {
  /// Allow/disallow by day of week
  DayPrefs dayPrefs;

  /// IANA string corresponding to user's time zone
  String timezone;

  /// Maximum notifications allowed per day
  int maxPerDay;

  /// Minimum time (in minutes) between successive notifications
  int minWindow;

  /// Whether to allow notifications while user movement is detected
  bool allowOnTheMove;

  /// Whether to allow notofocations while commuting is detected
  bool allowOnCommute;

  /// Whether to allow live quiz notifications while calendar has event
  bool allowLiveIfCalendar;

  /// Whether to allow self-paced (smart live) notifications while calendar
  /// has event
  bool allowSelfPacedIfCalendar;

  /// SSID of work wifi
  bool workSSID;

  /// Lat/long (and possibly name) of work
  LocationData workLocation;

  /// Work location geofence in km
  int workRadius;

  /// Whether the user has enabled residential/commercial auto-detection
  bool workSmart;

  NotificationPrefs.internal(
      this.dayPrefs,
      this.timezone,
      this.maxPerDay,
      this.minWindow,
      this.allowOnTheMove,
      this.allowOnCommute,
      this.allowLiveIfCalendar,
      this.allowSelfPacedIfCalendar,
      this.workSSID,
      this.workLocation,
      this.workRadius,
      this.workSmart);

  factory NotificationPrefs.fromJson(Map<String, dynamic> json) =>
      NotificationPrefs.internal(
          DayPrefs(prefs: json['days']),
          json['timezone'],
          json['maxNotificationsPerDay'],
          json['notificationWindow'],
          json['onTheMove'],
          json['onCommute'],
          json['calendarLive'],
          json['calendarSelfPaced'],
          json['workSSID'],
          LocationData.fromJson(json['workLocation']),
          json['workRadius'],
          json['workSmart']);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'days': dayPrefs._prefs,
        'timezone': timezone,
        'maxNotificationsPerDay': maxPerDay,
        'notificationWindow': minWindow,
        'calendarLive': allowLiveIfCalendar,
        'calendarSelfPaced': allowSelfPacedIfCalendar,
        'workSSID': workSSID,
        'workLocation': workLocation.toJson(),
        'workRadius': workRadius,
        'workSmart': workSmart
      };

  operator ==(Object other) {
    return other is NotificationPrefs &&
        dayPrefs == other.dayPrefs &&
        timezone == other.timezone &&
        maxPerDay == other.maxPerDay &&
        minWindow == other.minWindow &&
        allowOnTheMove == other.allowOnTheMove &&
        allowOnCommute == other.allowOnCommute &&
        allowLiveIfCalendar == other.allowLiveIfCalendar &&
        allowSelfPacedIfCalendar == other.allowSelfPacedIfCalendar &&
        workSSID == other.workSSID &&
        workLocation == other.workLocation &&
        workRadius == other.workRadius &&
        workSmart == other.workSmart;
  }

  get hashCode => hash4(
      dayPrefs.hashCode,
      hash4(timezone, maxPerDay, minWindow, allowOnTheMove),
      hash4(allowOnCommute, allowLiveIfCalendar, allowSelfPacedIfCalendar,
          workSSID),
      hash3(workLocation.hashCode, workRadius, workSmart));
}

enum Day { MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY }

class DayPrefs {
  List<bool> _prefs;

  DayPrefs({List<bool> prefs})
      : this._prefs =
            prefs ?? [false, false, false, false, false, false, false];

  void setPrefs(List<bool> prefs) {
    this._prefs = prefs;
  }

  List<bool> getPrefs() {
    return _prefs;
  }

  operator ==(Object other) {
    return other is DayPrefs &&
        ListEquality().equals(this._prefs, other._prefs);
  }

  get hashCode => _prefs.hashCode;
}

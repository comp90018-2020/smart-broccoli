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

  NotificationPrefs.internal(
      this.dayPrefs,
      this.timezone,
      this.maxPerDay,
      this.minWindow,
      this.allowOnTheMove,
      this.allowOnCommute,
      this.allowLiveIfCalendar,
      this.allowSelfPacedIfCalendar,
      this.workSSID);

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
          json['workSSID']);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'days': dayPrefs.prefs,
        'timezone': timezone,
        'maxNotificationsPerDay': maxPerDay,
        'notificationWindow': minWindow,
        'calendarLive': allowLiveIfCalendar,
        'calendarSelfPaced': allowSelfPacedIfCalendar,
        'workSSID': workSSID
      };
}

enum Day { MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY }

class DayPrefs {
  final List<bool> prefs;

  DayPrefs({List<bool> prefs})
      : this.prefs = prefs ?? [false, false, false, false, false, false, false];

  bool getPref(Day day) => prefs[day.index];
  void setPref(Day day, bool pref) {
    prefs[day.index] = pref;
  }
}

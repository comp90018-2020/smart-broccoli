import 'dart:collection';
import 'dart:developer';

import 'package:device_calendar/device_calendar.dart';

import '../background_database.dart';

class BackgroundCalendar {
  /// This should only be run on release mode and on a foreground thread
  /// https://github.com/builttoroam/device_calendar/issues/217
  static saveCalendarData(DeviceCalendarPlugin deviceCalendarPlugin) async {
    await BackgroundDatabase.init();
    await BackgroundDatabase.cleanEvent();

    List<Result<UnmodifiableListView<Event>>> e = [];
    List<Event> ev = [];
    deviceCalendarPlugin = new DeviceCalendarPlugin();
    var cal = await deviceCalendarPlugin.retrieveCalendars();
    List<Calendar> calendar = cal.data;

    log(
        "Calendar" +
            calendar.toString() +
            "Length:" +
            calendar.length.toString(),
        name: "Backend-Calendar");

    // Define the time frame
    var now = new DateTime.now();
    // Define that we want events from now to 7 days later
    RetrieveEventsParams retrieveEventsParams = new RetrieveEventsParams(
        startDate: now, endDate: now.add(new Duration(days: 7)));
    // Find all events within 7 days
    for (var i = 0; i < calendar.length; i++) {
      e.add(await deviceCalendarPlugin.retrieveEvents(
          calendar[i].id, retrieveEventsParams));
    }

    /// Intermediate step to check if every event is extracted
    for (var j = 0; j < e.length; j++) {
      if (e[j].isSuccess) {
        ev = ev + e[j].data.toList();
      } else {
        print(e[j].errorMessages);
      }
    }

    log("Events:" + ev.toString(), name: "Backend-Calendar");

    /// Write the data into the datatebase
    /// Which only stores the start time since Epoch
    /// And end time since Epoch
    for (var j = 0; j < ev.length; j++) {
      CalEvent calEvent = new CalEvent(
          id: j,
          start: ev[j].start.millisecondsSinceEpoch,
          end: ev[j].end.millisecondsSinceEpoch);

      await BackgroundDatabase.insertEvent(calEvent);
    }
    BackgroundDatabase.closeDB();
  }
}

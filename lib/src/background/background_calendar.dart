import 'dart:collection';
import 'dart:developer';

import 'package:device_calendar/device_calendar.dart';

import 'background_database.dart';

class BackgroundCalendar {
  static saveCalendarData() async {
    // Init database and clean past events
    var db = await BackgroundDatabase.init();
    await db.cleanEvents();

    // Retrieve calendars
    List<Result<UnmodifiableListView<Event>>> resultEvents = [];
    try {
      DeviceCalendarPlugin deviceCalendarPlugin = new DeviceCalendarPlugin();
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
        resultEvents.add(await deviceCalendarPlugin.retrieveEvents(
            calendar[i].id, retrieveEventsParams));
      }
    } catch (err) {
      log(err.toString(), name: "Backend calendar");
      return;
    }

    /// Intermediate step to check if every event is extracted
    List<Event> outputEvents = [];
    for (var i = 0; i < resultEvents.length; i++) {
      /// Check if sucess
      if (resultEvents[i].isSuccess) {
        outputEvents = outputEvents + resultEvents[i].data.toList();
      } else {
        log("Events error:" + resultEvents[i].errorMessages.toString(),
            name: "Backend calendar");
      }
    }
    log("Events:" + outputEvents.toString(), name: "Backend calendar");

    /// Write the data into the database which only stores the start time since
    /// epoch and end time since Epoch
    for (var i = 0; i < outputEvents.length; i++) {
      CalEvent calEvent = new CalEvent(
          id: i,
          start: outputEvents[i].start.millisecondsSinceEpoch,
          end: outputEvents[i].end.millisecondsSinceEpoch);
      await db.insertEvent(calEvent);
    }

    // Close database
    await db.closeDB();
  }
}

import 'dart:collection';
import 'dart:developer';

import 'package:device_calendar/device_calendar.dart';

import '../background_database.dart';

class BackgroundCalendar {
  static saveCalendarData() async {
    await BackgroundDatabase.init();
    await BackgroundDatabase.cleanEvent();

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
    List<Result<UnmodifiableListView<Event>>> resultEvents = [];
    // Find all events within 7 days
    for (var i = 0; i < calendar.length; i++) {
      resultEvents.add(await deviceCalendarPlugin.retrieveEvents(
          calendar[i].id, retrieveEventsParams));
    }

    List<Event> outputEvents = [];

    /// Intermediate step to check if every event is extracted
    for (var j = 0; j < resultEvents.length; j++) {
      /// Check if sucess
      if (resultEvents[j].isSuccess) {
        outputEvents = outputEvents + resultEvents[j].data.toList();
      } else {
        log("Events error:" + resultEvents[j].errorMessages.toString(),
            name: "Backend-Calendar");
      }
    }

    log("Events:" + outputEvents.toString(), name: "Backend-Calendar");

    /// Write the data into the datatebase
    /// Which only stores the start time since Epoch
    /// And end time since Epoch
    for (var j = 0; j < outputEvents.length; j++) {
      CalEvent calEvent = new CalEvent(
          id: j,
          start: outputEvents[j].start.millisecondsSinceEpoch,
          end: outputEvents[j].end.millisecondsSinceEpoch);

      await BackgroundDatabase.insertEvent(calEvent);
    }
    await BackgroundDatabase.closeDB();
  }
}

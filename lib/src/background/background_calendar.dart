import 'dart:collection';

import 'package:device_calendar/device_calendar.dart';

class BackgroundCalendar {
  List<Calendar> calendar;
  List<Event> events = [];
  DeviceCalendarPlugin deviceCalendarPlugin = new DeviceCalendarPlugin();

  Future<void> getBackground() async {
    Result<bool> hasPermissions = await deviceCalendarPlugin.hasPermissions();
    // Check permissions
    if (hasPermissions.isSuccess) {
      // Get all the Calendars
      Result<UnmodifiableListView<Calendar>> cal =
          await deviceCalendarPlugin.retrieveCalendars();
      calendar = cal.data;

      var now = new DateTime.now();

      // Define the time frame
      RetrieveEventsParams retrieveEventsParams = new RetrieveEventsParams(
          startDate: now, endDate: now.add(new Duration(hours: 1)));

      // Find all events within an hour of now
      for (var i = 0; i < calendar.length; i++) {
        Result<UnmodifiableListView<Event>> e = await deviceCalendarPlugin
            .retrieveEvents(calendar[i].id, retrieveEventsParams);
        events = events + e.data.toList();
      }
    } else {
      // Request permission or ignore
      deviceCalendarPlugin.requestPermissions();
    }
  }

  bool isEmpty() {
    return events.isEmpty;
  }
}

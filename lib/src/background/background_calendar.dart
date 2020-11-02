import 'dart:collection';

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/services.dart';

class BackgroundCalendar {
  List<Calendar> calendar;
  List<Event> events = [];
  DeviceCalendarPlugin deviceCalendarPlugin;

  BackgroundCalendar(DeviceCalendarPlugin dcp) {
    deviceCalendarPlugin = dcp;
  }

  void getBackground() async {

      print("GET all Calendars");
      Result<UnmodifiableListView<Calendar>> cal =
          await deviceCalendarPlugin.retrieveCalendars();
      calendar = cal.data;

      print("Calendar :" + calendar.toString());

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
      print("Events" + events.toString());
  }

  bool isEmpty() {
    return events.isEmpty;
  }
}

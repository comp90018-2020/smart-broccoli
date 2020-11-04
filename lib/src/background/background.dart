import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors/sensors.dart';
import 'package:smart_broccoli/src/background/light_sensor.dart';
import 'package:smart_broccoli/src/background/network.dart';
import 'package:smart_broccoli/src/background/background_database.dart';
import 'package:workmanager/workmanager.dart';

import 'gyro.dart';
import 'location.dart';

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    try {
      print("Starting background tasks");

      switch (task) {
        case "backgroundReading":
          var db = await BackgroundDatabase.init();

          var calendarFree = true;
          var free = true;

          // Check calendar
          if (!(await checkCalendar(db))) {
            calendarFree = false;
          }

          // Check wifi
          if (await Network.isAtWork("blabh blah")) {
            free = false;
          }

          /// Check location sensitive issues
          if (free && await locationCheck(db)) {
            free = false;
          }

          // Send status to API (API always needs status)
          log("calendarFree: $calendarFree, free: $free");
          log("Reason: Phone is not stationary or asked not to be prompted or calendar is busy return 0",
              name: "Backend");

          await db.closeDB();
          break;
      }

      return Future.value(true);
    } on MissingPluginException catch (e) {
      print("You should probably implement some plugins" + e.toString());
      return Future.value(true);
    }
  });
}

/// Location sensitive functions
Future<bool> locationCheck(BackgroundDatabase db) async {
  /// Get current long lat
  Position position1 =
      await BackgroundLocation.getPosition().catchError((_) => null);

  /// If in Geofence
  if (position1 == null) return false;
  if (await BackgroundLocation.inGeoFence(
      await db.getGeoFence(), position1, 1)) {
    log("The user is in a geofence return 1", name: "Backend");
    return true;
  }

  // /// Foreground test code
  // LocationAPI fl = new LocationAPI();
  // await fl.queryLonLat(position1.longitude, position1.latitude);
  // await fl.queryString("Melbourne");

  /// Idle for 30 seconds
  Duration duration = new Duration(seconds: 30);
  sleep(duration);

  /// Get second location
  Position position2 =
      await BackgroundLocation.getPosition().catchError((_) => null);
  if (position2 == null) return false;

  /// Check distance between the two
  double distance = Geolocator.distanceBetween(position1.latitude,
      position1.longitude, position2.latitude, position2.longitude);
  log("Distance" + distance.toString(), name: "Backend");

  /// Determine if the user has moved about 100 m in 30 + a few seconds
  /// Todo add perf logic
  /// If the user is moving
  if (distance > 100) {
    log("The user is on a train", name: "Backend TODO");
    // Check if on train
    if ((await BackgroundLocation.onTrain(position2))) {
      log("The user is on a train", name: "Backend TODO");

      /// If allow prompts on move or not logic here
      return false;
    }

    /// Not on train and moving
    /// Check if allow prompts on the move
    else {
      log("Not on a train and moving", name: "Backend TODO");
      return false;
    }
  }

  /// If the user is not moving
  else {
    String data = await BackgroundLocation.placeMarkType(position1)
        .catchError((_) => null);

    /// Not at a residential address or university
    if (data != null &&
        (data.contains("office") ||
            data.contains("commercial") ||
            data.contains("gym") ||
            data.contains("park"))) {
      // Return 0
      log("The defult location is GOOGLE HQ", name: "Backend-NOTE");
      log("We are at a Do not send notif area", name: "Backend");
      return false;
    } else {
      return lightGyro();
    }
  }
}

Future<bool> lightGyro() async {
  // Access Light sensor
  int lum = await LightSensor.getLightReading().catchError((_) => null);
  log("Lum $lum", name: "Backend");
  if (lum == null) return false;

  // Todo you may want to change 20 to a config value
  if (lum > 10 /* && reading < 70 */) {
    log("Reason: high light, return 1", name: "Backend");
    return true;
  }

  // If the time is at night
  DateTime dateTime = DateTime.now();
  if (dateTime.hour > 18 && dateTime.hour < 23) {
    log("Reason: notif sent because time is at night, return 1",
        name: "Backend");
    return true;
  } else {
    // Check if the phone is stationary and not being used
    if (await checkGyro()) {
      // Send notifification
      return false;
    }
  }
  return false;
}

Future<bool> checkCalendar(BackgroundDatabase db) async {
  List<CalEvent> calEvent = await db.getEvents();
  DateTime time = DateTime.now();
  for (var i = 0; i < calEvent.length; i++) {
    // Get event start/end in DateTime
    var eventStart = DateTime.fromMillisecondsSinceEpoch(calEvent[i].start);
    var eventEnd = DateTime.fromMillisecondsSinceEpoch(calEvent[i].end);

    // In middle of event right now
    if (timeIsBetween(time, eventStart, eventEnd)) {
      log("In middle of event", name: "Backend");
      return false;
    }

    // Event start in next 15 minutes
    if (timeIsBetween(eventStart, time, time.add(Duration(minutes: 15)))) {
      log("Event start in next 15 minutes", name: "Backend");
      return false;
    }
  }
  return true;
}

/// Returns value indicating whether time is between start and end
bool timeIsBetween(DateTime time, DateTime start, DateTime end) {
  return time.isAfter(start) && time.isBefore(end);
}

Future<bool> checkGyro() async {
  // Check if the phone is stationary and not being used
  GyroscopeEvent gyroscopeEvent =
      await Gyro.getGyroEvent().catchError((_) => null);
  log("Gyro Data Raw: " + gyroscopeEvent.toString(), name: "Backend");
  if (gyroscopeEvent == null) return true;

  double x = gyroscopeEvent.x;
  double y = gyroscopeEvent.y;
  double z = gyroscopeEvent.z;
  log("Gyro Data: " + x.toString() + " " + y.toString() + " " + z.toString(),
      name: "Backend");

  /// If phone is stationary
  /// TODO gyro is best tested on a real phone
  if ((x.abs() < 0.01) && (y.abs() < 0.01) && (z.abs() < 0.01)) {
    log("Reason: notif sent because phone is likely stationary, return 1",
        name: "Backend");
    return true;
  }
  return false;
}

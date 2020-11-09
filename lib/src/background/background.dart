import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:light/light.dart';
import 'package:sensors/sensors.dart';
import 'package:smart_broccoli/src/background/background_database.dart';
import 'package:smart_broccoli/src/background/light_sensor.dart';
import 'package:smart_broccoli/src/background/network.dart';
import 'package:smart_broccoli/src/data/prefs.dart';
import 'package:smart_broccoli/src/local.dart';
import 'package:smart_broccoli/src/remote.dart';
import 'package:workmanager/workmanager.dart';

import 'gyro.dart';
import 'location.dart';

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    try {
      print("Starting background tasks");

      switch (task) {
        case "backgroundReading":
          // User preferences
          final KeyValueStore keyValueStore =
              await SharedPrefsKeyValueStore.create();
          final String token = keyValueStore.getString('token');
          final String prefsAsJson = keyValueStore.getString('prefs');
          NotificationPrefs notificationPrefs;
          if (prefsAsJson != null) {
            notificationPrefs =
                NotificationPrefs.fromJson(json.decode(prefsAsJson));
          }

          log("Background Reading", name: "background");
          if (token == null) {
            log("Token is null", name: "background");
            break;
          }
          if (notificationPrefs == null) {
            log("Perferences is null", name: "background");
            break;
          }

          // load prefs
          var calendarFree = true;
          var free = true;

          // Check calendar
          try {
            var db = await BackgroundDatabase.init();
            if (!(await checkCalendar(db))) {
              calendarFree = false;
            }
            await db.closeDB();
          } catch (e) {
            calendarFree = true;
          }

          log("Calendar Check Complete", name: "background");

          // Check wifi
          if (await Network.workWifiMatch(notificationPrefs.workSSID) &&
              notificationPrefs.workSmart) {
            free = false;
          }

          log("Network Check Complete", name: "background");

          /// Check location sensitive issues
          if (free && !(await locationCheck(notificationPrefs))) {
            free = false;
          }

          log("Location Check complete token:" + token.toString(),
              name: "background");

          UserApi userApi = new UserApi();
          try {
            await userApi.setFree(token, calendarFree, free);
          } catch (e) {
            log(e.toString());
          }

          // Send status to API (API always needs status)
          log("calendarFree: $calendarFree, free: $free");
          log("Reason: Phone is not stationary or asked not to be prompted or calendar is busy return 0",
              name: "Backend");
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
/// returns true if the user is free
Future<bool> locationCheck(NotificationPrefs notificationPrefs) async {
  /// Get current long lat
  Position position1 =
      await BackgroundLocation.getPosition().catchError((_) => null);

  log("Start Positional Analysis", name: "Backend");
  log(notificationPrefs.workLocation.toJson().toString(), name: "Backend");
  log(notificationPrefs.workRadius.toString(), name: "Backend");

  /// If in Geofence
  if (position1 == null) return false;

  if (notificationPrefs.workLocation != null) {
    /// WELCOME TO THE CODING DANGER ZONE
    if (notificationPrefs.workSmart != null && notificationPrefs.workRadius != null && notificationPrefs.workLocation != null) {
      if (await BackgroundLocation.inGeoFence(notificationPrefs.workLocation,
              position1, notificationPrefs.workRadius) &&
          notificationPrefs.workSmart) {
        log(
            "Location Geofenced: " +
                notificationPrefs.workLocation.name +
                "lon" +
                notificationPrefs.workLocation.lon.toString() +
                "lat" +
                notificationPrefs.workLocation.lat.toString(),
            name: "Backend");
        log("The user is in a geofence return 0", name: "Backend");
        return false;
      }
    }
    /// End of the coding danger zone
  }

  log("Start Positional Analysis 2", name: "Backend");

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
  log(
      "Distance" +
          distance.toString() +
          "CHOOO CHOOOOO" +
          notificationPrefs.allowOnCommute.toString(),
      name: "Backend");

  /// Determine if the user has moved about 50 m in 30 + a few seconds
  /// Todo add perf logic
  /// If the user is moving
  if (distance > 50) {
    log("The user is Moving", name: "Backend");
    // Check if on train
    if ((await BackgroundLocation.onTrain(position2)) &&
        notificationPrefs.allowOnCommute) {
      log("The user is on a train send notif", name: "Backend");

      /// If allow prompts on move or not logic here
      return true;
    }

    /// Not on train and moving
    /// Check if allow prompts on the move
    else {
      log("Not on a train and moving", name: "Backend");
      return notificationPrefs.allowOnTheMove;
    }
  }

  /// If the user is not moving
  else {
    log("User is not moving", name: "Backend");
    String data = await BackgroundLocation.placeMarkType(position1)
        .catchError((_) => null);

    /// Not at a residential address or university
    if (data != null &&
        (data.contains("office") ||
            data.contains("commercial") ||
            data.contains("fitness") ||
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

int onTimeOutLight() {
  LightSensor.close();
  return 0;
}

Future<bool> lightGyro() async {
  // Access Light sensor
  Duration duration = new Duration(seconds: 10);
  int lum = await LightSensor.getLightReading()
      .timeout(duration, onTimeout: onTimeOutLight);
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
      return true;
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

GyroscopeEvent onTimeOutGyro() {
  Gyro.cancel();
  return new GyroscopeEvent(0.0, 0.0, 0.0);
}

Future<bool> checkGyro() async {
  // Check if the phone is stationary and not being used
  Duration duration = new Duration(seconds: 10);
  GyroscopeEvent gyroscopeEvent =
      await Gyro.getGyroEvent().timeout(duration, onTimeout: onTimeOutGyro);

  if (gyroscopeEvent == null) return true;
  double x = gyroscopeEvent.x;
  double y = gyroscopeEvent.y;
  double z = gyroscopeEvent.z;
  log("Gyro Data: " + x.toString() + " " + y.toString() + " " + z.toString(),
      name: "Backend");

  /// If phone is stationary
  if ((x.abs() < 0.01) && (y.abs() < 0.01) && (z.abs() < 0.01)) {
    log("Reason: notif sent because phone is likely stationary, return 1",
        name: "Backend");
    return true;
  }
  return false;
}

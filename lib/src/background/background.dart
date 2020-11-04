import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors/sensors.dart';
import 'package:smart_broccoli/src/background/light_sensor.dart';
import 'package:smart_broccoli/src/background/network.dart';
import 'package:smart_broccoli/src/background_database.dart';
import 'package:wifi_info_plugin/wifi_info_plugin.dart';
import 'package:workmanager/workmanager.dart';

import 'gyro.dart';
import 'location.dart';

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    try {
      print("Starting background tasks");
      switch (task) {
        case "backgroundReading":
          await BackgroundDatabase.init();

          if (!(await checkCalendar())) {
            // Don't send notification
            break;
          }

          /// The wifi and location stuff is used continuously throughout
          /// The decision tree so it is a bit hard to abstract these info
          /// Out.
          Network network = new Network();

          await network.initConnectivity();

          String status = await network.connectionStatus;

          if (status == ConnectivityResult.wifi.toString()) {
            await network.initWifiInfro();
            WifiInfoWrapper wifiObj = network.wifiObject;
            print(wifiObj.ssid);

            if (wifiObj.ssid.contains("staff") ||
                wifiObj.ssid.contains("work")) {
              // Return 0
              log("The user's wifi appears to be work wifi return 0",
                  name: "Backend");

              break;
            }
          }

          log("Connectivity Status" + status, name: "Backend");

          /// Start location stuff
          BackgroundLocation backgroundLocation = new BackgroundLocation();

          /// Get current long lat
          Position position1 = await backgroundLocation.getPosition();

          /// If in Geofence
          if ((await backgroundLocation.inGeoFence(position1))) {
            /// Return 1
            log("The user is in a geofence return 1", name: "Backend");
            break;
          }

          /// Idle for 30 seconds
          Duration duration = new Duration(seconds: 30);

          /// Idle background process for a while
          sleep(duration);

          /// Get second location
          Position position2 = await backgroundLocation.getPosition();

          /// Check distance between the two
          double distance = Geolocator.distanceBetween(position1.latitude,
              position1.longitude, position2.latitude, position2.longitude);

          log("Position 1" + distance.toString(), name: "Backend");

          /// Determine if the user has moved about 100 m in 30 + a few seconds
          /// Todo add perf logic
          /// If the user is moving
          if (distance > 100) {
            log("The user is on a train", name: "Backend TODO");
            // Check if on train
            if ((await backgroundLocation.onTrain(position2))) {
              log("The user is on a train", name: "Backend TODO");

              /// If allow prompts on move or not logic here
              break;
            }

            /// Not on train and moving
            /// Check if allow prompts on the move
            else {
              log("Not on a train and moving", name: "Backend TODO");
              break;
            }
          }

          /// If the user is not moving
          else {
            String data = await backgroundLocation.placeMarkType(position1);

            /// Not at a residential address or university
            if (data.contains("office") ||
                data.contains("commercial") ||
                data.contains("gym") ||
                data.contains("park")) {
              // Return 0
              log("The defult location is GOOGLE HQ", name: "Backend-NOTE");
              log("We are at a Do not send notif area", name: "Backend");
              break;
            }

            // Access Light sensor
            LightSensor lightSensor = new LightSensor();
            int lum = await lightSensor.whenLight();

            log("Lum" + lum.toString(), name: "Backend");

            lightSensor.close();

            // Todo you may want to change 20 to a config value
            if (lum > 10 /*&& reading < 70 */) {
              log("Reason: high light, return 1", name: "Backend");

              break;
            } else {
              /// If the time is at night //todo add config
              DateTime dateTime = DateTime.now();
              if (dateTime.hour > 18 && dateTime.hour < 23) {
                log("Reason: notif sent because time is at night, return 1",
                    name: "Backend");
                break;
              } else {
                // Check if the phone is stationary and not being used
                if (await checkGyro()) {
                  // Send notif
                  break;
                }
              }
            }
          }

          /// Return 0
          log("Reason: Phone is not stationary or asked not to be prompted or calendar is busy return 0",
              name: "Backend");

          break;
      }

      /// Close the SQL database
      await BackgroundDatabase.closeDB();
      return Future.value(true);
    } on MissingPluginException catch (e) {
      print("You should probably implement some plugins" + e.toString());
      return Future.value(true);
    }
  });
}

Future<bool> checkCalendar() async {
  List<CalEvent> calEvent = await BackgroundDatabase.getEvents();
  DateTime time = DateTime.now();
  // TODO test calendar events
  for (var i = 0; i < calEvent.length; i++) {
    /// 3 600 000 is exactly an hour in miliseconds 900000 is 15 minutes
    if ((calEvent[i].start > time.millisecondsSinceEpoch &&
            calEvent[i].start < time.millisecondsSinceEpoch + 900000) &&
        (calEvent[i].end > time.millisecondsSinceEpoch &&
            calEvent[i].end < time.millisecondsSinceEpoch + 900000)) {
      // Return 0
      log("The user is busy today accoridng to cal return 0", name: "Backend");
      return false;
    }
  }
  return true;
}

Future<bool> checkGyro() async {
  // Check if the phone is stationary and not being used
  Gyro gyro = new Gyro();
  GyroscopeEvent gyroscopeEvent = await gyro.whenGyro();
  double x1 = gyroscopeEvent.x;
  double y1 = gyroscopeEvent.y;
  double z1 = gyroscopeEvent.z;

  gyro.gyroCancel();
  log("Gyro Data: " + x1.toString() + " " + y1.toString() + " " + z1.toString(),
      name: "Backend");

  /// If phone is stationary
  /// TODO gyro is best tested on a real phone
  if ((x1.abs() < 0.01) && (y1.abs() < 0.01) && (z1.abs() < 0.01)) {
    log("Reason: notif sent because phone is likely stationary, return 1",
        name: "Backend");
    return true;
  }
  return false;
}

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
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
          bool flag = false;
          await BackgroundDatabase.init();
          List<CalEvent> calEvent = await BackgroundDatabase.getEvents();
          DateTime time = DateTime.now();
          // TODO test calendar events
          // print("Time " + tiem.millisecondsSinceEpoch.toString());
          for (var i = 0; i < calEvent.length; i++) {
            /*
            print("CAL EVENTS" +
                calEvent[i].start.toString() +
                " " +
                calEvent[i].end.toString());

             */

            /// 3 600 000 is exactly an hour in miliseconds
            if (calEvent[i].start < time.millisecondsSinceEpoch &&
                calEvent[i].end > time.millisecondsSinceEpoch + 3600000) {
              // Return 0
              log("The user is busy today accoridng to cal return 0",
                  name: "Backend");
              flag = true;
              break;
            }
          }
          // For code above
          if (flag) {
            break;
          }

          /// Check wifi for work wifi stuff
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
          print(status);

          /// Start location stuff
          BackgroundLocation backgroundLocation = new BackgroundLocation();

          /// Get current long lat
          Position position1 = await backgroundLocation.getPosition();

          /*

          Debug Test code
          print("Position 1 " +
              position1.longitude.toString() +
              " " +
              position1.latitude.toString());

          BackgroundDatabase.insertFence(GeoFence(id: 0, lon: 1, lat: 1));
          BackgroundDatabase.insertFence(
              GeoFence(id: 1, lon: -122.078827, lat: 37.419857));
            */

          /// If in Geofence
          if ((await backgroundLocation.inGeoFence(position1))) {
            /// Return 1
            log("The user is in a geofence return 1", name: "Backend");
            break;
          }

          /// Check location info
          Placemark placemark =
              await backgroundLocation.getPlacemark(position1);

          String data = await backgroundLocation.placeMarkType(placemark);

          /// Not at a residential address or university
          if (data.contains("office") || data.contains("commercial")) {
            // Return 0
            log("The defult location is GOOGLE HQ", name: "Backend-NOTE");
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
              position1.longitude, position1.latitude, position2.longitude);

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
            // Access Light sensor
            LightSensor lightSensor = new LightSensor();
            int lum = await lightSensor.whenLight();

            log("Lum" + lum.toString(), name: "Backend");

            lightSensor.close();

/*
            // Access the microphone sensor
            Microphone microphone = new Microphone();
            await microphone.start();
            print("Microphone started");
            double reading = await microphone.getReading();
            print("Stopping Microphone");
            microphone.stop(); */

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
                Gyro gyro = new Gyro();
                // Determine phone movement, i.e is teh user currently using
                // The phone also determine if we need to sleep below
                duration = new Duration(seconds: 5);
                sleep(duration);
                GyroscopeEvent gyroscopeEvent = await gyro.whenGyro();
                double x1 = gyroscopeEvent.x;
                double y1 = gyroscopeEvent.y;
                double z1 = gyroscopeEvent.z;

                gyro.gyroCancel();
                log(
                    "Gyro Data: " +
                        x1.toString() +
                        " " +
                        y1.toString() +
                        " " +
                        z1.toString(),
                    name: "Backend");

                /// If phone is stationary
                /// TODO gyro is best tested on a real phone
                if ((x1.abs() < 0.01) &&
                    (y1.abs() < 0.01) &&
                    (z1.abs() < 0.01)) {
                  log("Reason: notif sent because phone is likely stationary, return 1",
                      name: "Backend");
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
      BackgroundDatabase.closeDB();
      return Future.value(true);
    } on MissingPluginException catch (e) {
      print("You should probably implement some plugins" + e.toString());
      return Future.value(true);
    }
  });
}

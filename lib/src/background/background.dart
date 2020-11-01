import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smart_broccoli/src/background/background_calendar.dart';
import 'package:smart_broccoli/src/background/gyro.dart';
import 'package:smart_broccoli/src/background/light_sensor.dart';
import 'package:smart_broccoli/src/background/location.dart';
import 'package:workmanager/workmanager.dart';

/*
* <osm-script>
  <union into="_">
    <query into="_" type="way">
      <has-kv k="railway" modv="" regv="^(rail|subway|tram)$"/>
      <bbox-query s="51.451" w="7.009" n="51.453" e="7.011"/>
    </query>
    <recurse from="_" into="_" type="down"/>
  </union>
  <print e="" from="_" geometry="skeleton" ids="yes" limit="" mode="body" n="" order="id" s="" w=""/>
</osm-script>

*
* */

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    try {
      switch (task) {
        case "backgroundReading":
          BackgroundCalendar backgroundCalendar = new BackgroundCalendar();

          // Retrieve the calandar events in the backgorund
          await backgroundCalendar.getBackground();
          // Getter
          if (!backgroundCalendar.isEmpty()) {
            // Todo add failure condition
            break;
          }







          // Check if user is moving
          // Todo add pedometer
          BackgroundLocation backgroundLocation = new BackgroundLocation();



          Position position1 = await backgroundLocation.getPosition();

          if((await backgroundLocation.inGeoFence(position1))){
            // TODO send a notif
            break;
          }


          Duration duration = new Duration(seconds: 30);

          // Idle background process for a while
          sleep(duration);

          Position position2 = await backgroundLocation.getPosition();

          double distance = Geolocator.distanceBetween(position1.latitude, position1.longitude,
              position1.longitude, position2.longitude);

          // Main branch 1
          if(distance > 1000){
            // Check if on train
            if(!(await backgroundLocation.onTrain(position2))){
              // Todo don't send notif
              break;
            }
            // Todo check if allows prompt on commute

          }
          else{
            LightSensor lightSensor = new LightSensor();
            lightSensor.startListeningLight();
            int lum = lightSensor.Lumval;
            lightSensor.stopListeningLight();

            //TODO check if lum != null light sensor stream is closed

            DateTime dateTime = DateTime.now();
            // Todo you may want to change 20 to a config value
            if(lum > 10 ){
              // Todo send a quiz
              break;
            }
            else{
              if(dateTime.hour > 18 && dateTime.hour < 23){
                //Todo send quiz

              }
              else{
                Gyro gyro = new Gyro();
                // TODO determine gyro values, either up down left n right
                gyro.gyroscopeValues[0];





              }
            }







          }
          break;
      }
      return Future.value(true);
    } on MissingPluginException catch (e) {
      print("You should probably implement some plugins :D");
      return Future.value(true);
    }
  });
}

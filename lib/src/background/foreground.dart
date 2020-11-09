import 'package:flutter_foreground_plugin/flutter_foreground_plugin.dart';
import 'package:light/light.dart';
import 'package:smart_broccoli/src/background/background.dart';
import 'package:smart_broccoli/src/background/gyro.dart';
import 'package:smart_broccoli/src/background/light_sensor.dart';

void startForegroundService() async {
  await FlutterForegroundPlugin.setServiceMethodInterval(seconds: 5);
  await FlutterForegroundPlugin.setServiceMethod(globalForegroundService);

  await FlutterForegroundPlugin.startForegroundService(
    holdWakeLock: false,
    onStarted: () {
      print("Foreground on Started");
    },
    onStopped: () {
      print("Foreground on Stopped");
    },
    iconName: "icon.png",
    title: "Smart Quiz Foreground/Background Service",
    content:
        "If this tab is on, it means that the background and foreground services of smart quiz is working as intended",
  );
}

void globalForegroundService() {
  print("We are starting Foreground services");
  Gyro.getGyroEvent();
  LightSensor.getLightReading();
  print("We have completed Foreground Services");
}

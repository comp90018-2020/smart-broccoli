import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:light/light.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:smart_broccoli/notification.dart';
import 'package:wifi_info_plugin/wifi_info_plugin.dart';
import 'package:workmanager/workmanager.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:geocoding/geocoding.dart';

// Make functions for these
// Workload manager
// Method channel if Kotlin is ever used
const MethodChannel platform = const MethodChannel('background');
// Wifi and Cellular data
String _connectionStatus = 'Unknown';
final Connectivity _connectivity = Connectivity();
StreamSubscription<ConnectivityResult> _connectivitySubscription;
WifiInfoWrapper _wifiObject;
// Light Sensor
String _luxString = 'Unknown';
Light _light;
StreamSubscription _lightStream;
// Microphone Sensor
bool _isRecording = false;
StreamSubscription<NoiseReading> _noiseSubscription;
NoiseMeter _noiseMeter;
List<StreamSubscription<dynamic>> _streamSubscriptions =
    <StreamSubscription<dynamic>>[];
String recordingData;
int LuxValue;


void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    try {
      switch (task) {
        case "backgroundReading":
          print("Task running on background");

          Position userLocation = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

          print("Done");
          Notification notification = new Notification();
          print("Sending Notification");
          await notification.showNotificationWithoutSound(userLocation);

          break;

      }
      return Future.value(true);
    } on MissingPluginException catch (e) {
      print("You should probably implement some plugins :D");
      return Future.value(true);
    }
  });
}

// TODO Put everythin in it's own file
/// Code for Location Data
Position getUserLocation() {}

/// Code for intercepting and processing light data
/// Functions includes
/// onLightData
/// startListeningLight
/// StopListeningLight

void onLightData(int luxValue) async {
  LuxValue = luxValue;
}

void stopListeningLight() {
  _lightStream.cancel();
}

Future<void> startListeningLight() async {
  _light = new Light();
  try {
    _lightStream = _light.lightSensorStream.listen(onLightData);
  } on LightException catch (exception) {
    print(exception);
  }
}

/// Connectivity, determines if WIFI or Mobile connection
// Platform messages are asynchronous, so we initialize in an async method.
Future<void> initConnectivity() async {
  ConnectivityResult result;
  // Platform messages may fail, so we use a try/catch PlatformException.
  try {
    result = await _connectivity.checkConnectivity();
  } on PlatformException catch (e) {
    print(e.toString());
  }

  return _updateConnectionStatus(result);
}

Future<void> _updateConnectionStatus(ConnectivityResult result) async {
  switch (result) {
    case ConnectivityResult.wifi:
    case ConnectivityResult.mobile:
    case ConnectivityResult.none:
      _connectionStatus = result.toString();
      break;
    default:
      _connectionStatus = 'Failed to get connectivity.';
      break;
  }
}

/// This class determines WIFI INFO
/// Platform messages are asynchronous, so we initialize in an async method.
Future<void> initPlatformState() async {
  WifiInfoWrapper wifiObject;
  // Platform messages may fail, so we use a try/catch PlatformException.
  try {
    wifiObject = await WifiInfoPlugin.wifiDetails;
  } on PlatformException {}
  _wifiObject = wifiObject;
}

/// decibel data (Nearby noise)
void onDataRecording(NoiseReading noiseReading) {
  if (!_isRecording) {
    _isRecording = true;
  }
  recordingData = noiseReading.toString();
}

void startRecording() async {
  try {
    _noiseSubscription = _noiseMeter.noiseStream.listen(onDataRecording);
  } catch (err) {
    print(err);
  }
}

void stopRecording() async {
  try {
    if (_noiseSubscription != null) {
      _noiseSubscription.cancel();
      _noiseSubscription = null;
    }
    _isRecording = false;
  } catch (err) {
    print('stopRecorder error: $err');
  }
}

// TODO leave in a commit
/// If you wish to initialise Kotlin code then this function does it for you.
/// Placed here as a stub if we ever need kotlin code.
Future<void> _initBackground() async {
  print("******Starting Background Services *****");
  try {
    await platform.invokeMethod('beginBackground');
  } on PlatformException catch (e) {
    print("Failed Communication: '${e.message}'.");
  }
}

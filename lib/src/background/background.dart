import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:light/light.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:smart_broccoli/notification.dart';
import 'package:wifi_info_plugin/wifi_info_plugin.dart';
import 'package:workmanager/workmanager.dart';
import 'package:xml/xml.dart';

// TODO move these into their own functions
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

http.Client _http;

Future<HttpClientResponse> _sendOTP(
    String lon, String lat, String lon1, String lat1) async {
  final data = '''<?xml version="1.0" encoding="UTF-8"?>
<osm-script>
  <union into="_">
    <query into="_" type="way">
      <has-kv k="railway" modv="" regv="^(rail|subway|tram)"/>
      <bbox-query s="$lon" w="$lat" n="$lon1" e="$lat1"/>
    </query>
    <recurse from="_" into="_" type="down"/>
  </union>
  <print e="" from="_" geometry="skeleton" ids="yes" limit="" mode="body" n="" order="id" s="" w=""/>
</osm-script>''';

  final document = XmlDocument.parse(data);
  String _uriMsj = document.toString();
  print("uri msj =" + _uriMsj);

  String _uri = 'http://overpass-api.de/api/interpreter';

  http.Response response = await http.post(_uri, body: _uriMsj, headers: {
    'Content-type': 'text/xml',
  });

  print("Response code " + response.statusCode.toString());
  print("Response body " + response.body.toString());
}

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    try {
      switch (task) {
        case "backgroundReading":
          print("Task running on background");

          Position userLocation = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);

          print("Location reading complete Done");

          List<Placemark> placemark = await placemarkFromCoordinates(
              userLocation.latitude, userLocation.longitude);

          double lon1 = userLocation.longitude + 0.001;
          double lon2 = userLocation.longitude - 0.001;
          double lat1 = userLocation.latitude + 0.001;
          double lat2 = userLocation.latitude - 0.001;

          await _sendOTP(lat2.toString(), lon2.toString(), lat1.toString(),
              lon1.toString());

          print("Placemark " + placemark.toString());
          print("Placemark identification complete");

          Notification notification = new Notification();
          print("Sending Notification");
          await notification.showNotificationWithoutSound(
              userLocation, placemark.first);

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

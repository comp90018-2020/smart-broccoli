import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:wifi_info_plugin/wifi_info_plugin.dart';
import 'package:flutter/services.dart';

class Network {
  final Connectivity _connectivity = Connectivity();
  WifiInfoWrapper _wifiObject;
  String _connectionStatus;

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
  Future<void> initWifiInfro() async {
    WifiInfoWrapper wifiObject;
// Platform messages may fail, so we use a try/catch PlatformException.
    try {
      wifiObject = await WifiInfoPlugin.wifiDetails;
    } on PlatformException {}
    _wifiObject = wifiObject;
  }
}

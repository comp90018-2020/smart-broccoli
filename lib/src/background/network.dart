import 'dart:async';
import 'dart:developer';

import 'package:connectivity/connectivity.dart';
import 'package:wifi_info_plugin/wifi_info_plugin.dart';
import 'package:flutter/services.dart';

class Network {
  final Connectivity _connectivity = Connectivity();
  WifiInfoWrapper _wifiObject;
  String _connectionStatus;



  Future<List<String>> getNetworkStatus() async {
    await initConnectivity();
    if(_connectionStatus ==  ConnectivityResult.wifi.toString()) {
      await initWifiInfro();
      return [_connectionStatus,_wifiObject.ssid];
    }
    else{
      return [_connectionStatus,null];
    }
  }

  Future<bool> isAtWork(Network network) async{
    List<String> networkStats = await network.getNetworkStatus();

    if (networkStats[0] == ConnectivityResult.wifi.toString()) {
      if (networkStats[1].contains("staff") ||
          networkStats[1].contains("work")) {
        // Return 0
        log("The user's wifi appears to be work wifi return 0",
            name: "Backend");

        return true;
      }
    }
    return false;

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
  Future<void> initWifiInfro() async {
    WifiInfoWrapper wifiObject;
// Platform messages may fail, so we use a try/catch PlatformException.
    try {
      wifiObject = await WifiInfoPlugin.wifiDetails;
    } on PlatformException {}
    _wifiObject = wifiObject;
  }
}

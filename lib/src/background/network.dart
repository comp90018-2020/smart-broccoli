import 'dart:async';
import 'dart:developer';
import 'package:connectivity/connectivity.dart';
import 'package:wifi_info_plugin/wifi_info_plugin.dart';

// Temp class for passing status and ssid around
class NetworkState {
  final ConnectivityResult connectivityStatus;
  final String ssid;
  NetworkState(this.connectivityStatus, this.ssid);
}

class Network {
  // Determines whether user is at work
  static Future<bool> isAtWork(String ssid) async {
    NetworkState networkStats = await _getNetworkState();
    if (networkStats.connectivityStatus == ConnectivityResult.wifi) {
      if (networkStats.ssid == null) return false;
      var ssidLower = networkStats.ssid.toLowerCase();
      if (ssidLower.contains("staff") ||
          ssidLower.contains("work") ||
          ssidLower == ssid.toLowerCase()) {
        log("The user's wifi appears to be work wifi return 0",
            name: "Backend");
        return true;
      }
    }
    return false;
  }

  static Future<NetworkState> _getNetworkState() async {
    // Get connectivity type
    var connectivityStatus = await _getConnectivityStatus();
    if (connectivityStatus == ConnectivityResult.wifi) {
      // If wifi, return SSID
      var wifiObject = await _getWifiInfo();
      return NetworkState(connectivityStatus, wifiObject.ssid);
    } else {
      return NetworkState(connectivityStatus, null);
    }
  }

  /// Connectivity, determines if WIFI or Mobile connection
  /// Platform messages are asynchronous, so we initialize in an async method.
  static Future<ConnectivityResult> _getConnectivityStatus() async {
    try {
      return await Connectivity().checkConnectivity().catchError((_) => null);
    } catch (_) {
      return null;
    }
  }

  /// This class determines WIFI INFO
  /// Platform messages are asynchronous, so we initialize in an async method.
  static Future<WifiInfoWrapper> _getWifiInfo() async {
    try {
      return await WifiInfoPlugin.wifiDetails.catchError((_) => null);
    } catch (err) {
      return null;
    }
  }
}

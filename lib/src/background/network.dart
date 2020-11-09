import 'dart:async';
import 'dart:developer';
import 'package:wifi_info_plugin/wifi_info_plugin.dart';

class Network {
  // Determines whether user is at work
  static Future<bool> workWifiMatch(String ssid) async {
    if(ssid == null){
      return false;
    }


    var wifiInfo = await _getWifiInfo();
    if (wifiInfo == null || wifiInfo.ssid == null) return false;

    var ssidLower = wifiInfo.ssid.toLowerCase();
    if (ssidLower.contains("staff") ||
        ssidLower.contains("work") ||
        ssidLower == ssid.toLowerCase()) {
      log("The user's wifi appears to be work wifi return 0", name: "Backend");
      return true;
    }
    return false;
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

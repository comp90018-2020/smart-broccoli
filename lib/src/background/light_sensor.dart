import 'dart:async';

import 'package:async/async.dart' show StreamQueue;
import 'package:light/light.dart';

/// The Luminosity sensor
class LightSensor {
  static int globalLightVal;

  static Future<int> getLightReading() async {
    try {
      Light light = new Light();
      var queue = new StreamQueue(light.lightSensorStream);
      Duration duration = new Duration(seconds: 10);
      int val = await queue.next.timeout(duration, onTimeout: null);
      queue.cancel();
      globalLightVal = val;
      return val;
    } catch (e) {
      return Future.error("Light failed");
    }
  }
}

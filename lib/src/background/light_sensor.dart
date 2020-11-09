import 'dart:async';

import 'package:async/async.dart' show StreamQueue;
import 'package:light/light.dart';

/// The Luminosity sensor
class LightSensor {
  static Future<int> getLightReading() async {
    return await _getLightReading()
        .timeout(Duration(seconds: 10))
        .catchError((_) => 0);
  }

  static Future<int> _getLightReading() async {
    try {
      Light light = new Light();
      var queue = new StreamQueue(light.lightSensorStream);
      int val = await queue.next;
      queue.cancel();
      return val;
    } catch (e) {
      return Future.error("Light failed");
    }
  }
}

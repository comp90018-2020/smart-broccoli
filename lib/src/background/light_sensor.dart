import 'dart:async';

import 'package:async/async.dart' show StreamQueue;
import 'package:light/light.dart';

/// The Luminosity sensor
class LightSensor {
  static Future<int> getLightReading() async {
    try {
      Light light = new Light();
      var queue = new StreamQueue(light.lightSensorStream);
      Future<int> val = queue.next;
      queue.cancel();
      return val;
    } catch (e) {
      return Future.error("Light failed");
    }
  }
}

import 'dart:async';

import 'package:async/async.dart' show StreamQueue;
import 'package:light/light.dart';

/// The Luminosity sensor
class LightSensor {
  static var queue;

  static Future<int> getLightReading() async {
    try {
      Light light = new Light();
      queue = new StreamQueue(light.lightSensorStream);
      int val = await queue.next;
      queue.cancel();
      return val;
    } catch (e) {
      return Future.error("Light failed");
    }
  }

  static close() {
    queue.cancel();
  }
}

import 'dart:async';
import 'package:light/light.dart';
import 'package:async/async.dart' show StreamQueue;

/// The Luminosity sensor
class LightSensor {
  static Future<int> getLightReading() async {
    try {
      Light light = new Light();
      var queue = new StreamQueue(light.lightSensorStream);
      return await queue.next;
    } catch (e) {
      return Future.error("Light failed");
    }
  }
}

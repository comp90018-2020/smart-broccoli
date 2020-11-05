import 'dart:async';
import 'package:sensors/sensors.dart';
import 'package:async/async.dart' show StreamQueue;

/// Gryoscope readings
class Gyro {
  static Future<GyroscopeEvent> getGyroEvent() async {
    try {
      var queue = new StreamQueue(gyroscopeEvents);
      GyroscopeEvent gyroscopeEvent = await queue.next;
      queue.cancel();
      return gyroscopeEvent;
    } catch (e) {
      return Future.error("Gyroscope");
    }
  }
}
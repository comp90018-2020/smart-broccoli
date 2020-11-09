import 'dart:async';

import 'package:async/async.dart' show StreamQueue;
import 'package:sensors/sensors.dart';

/// Gryoscope readings
class Gyro {
  static Future<GyroscopeEvent> getGyroEvent() async {
    try {
      var queue = new StreamQueue(gyroscopeEvents);
      Future<GyroscopeEvent> gyroscopeEvent = queue.next;
      queue.cancel();
      return gyroscopeEvent;
    } catch (e) {
      return Future.error("Gyroscope");
    }
  }
}

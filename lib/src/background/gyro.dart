import 'dart:async';

import 'package:async/async.dart' show StreamQueue;
import 'package:sensors/sensors.dart';

/// Gryoscope readings
class Gyro {
  static GyroscopeEvent globalGyroscopeEvent;

  static Future<GyroscopeEvent> getGyroEvent() async {
    try {
      var queue = new StreamQueue(gyroscopeEvents);
      Duration duration = new Duration(seconds: 10);
      GyroscopeEvent gyroscopeEvent =
          await queue.next.timeout(duration, onTimeout: null);
      queue.cancel();
      globalGyroscopeEvent = gyroscopeEvent;
      return gyroscopeEvent;
    } catch (e) {
      return Future.error("Gyroscope");
    }
  }
}

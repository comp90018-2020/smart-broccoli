import 'dart:async';

import 'package:async/async.dart' show StreamQueue;
import 'package:sensors/sensors.dart';

/// Gryoscope readings
class Gyro {
  static var queue;

  static Future<GyroscopeEvent> getGyroEvent() async {
    try {
      queue = new StreamQueue(gyroscopeEvents);
      GyroscopeEvent gyroscopeEvent = await queue.next;
      queue.cancel();
      return gyroscopeEvent;
    } catch (e) {
      return Future.error("Gyroscope");
    }
  }

  static cancel() {
    queue.cancel();
  }
}

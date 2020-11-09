import 'dart:async';

import 'package:async/async.dart' show StreamQueue;
import 'package:sensors/sensors.dart';

/// Gryoscope readings
class Gyro {
  static Future<GyroscopeEvent> getGyroEvent() async {
    return await _getGyroEvent()
        .timeout(Duration(seconds: 10))
        .catchError((_) => null);
  }

  static Future<GyroscopeEvent> _getGyroEvent() async {
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

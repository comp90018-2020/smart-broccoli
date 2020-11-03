import 'dart:async';

import 'package:sensors/sensors.dart';

class Gyro {
  StreamController<GyroscopeEvent> controller =
      StreamController<GyroscopeEvent>();

  Gyro() {
    controller.addStream(gyroscopeEvents);
  }

  gyroCancel() {
    controller.close();
  }

  Future<GyroscopeEvent> whenGyro() async {
    await for (GyroscopeEvent value in controller.stream) {
      return value;
    }
    return null;
  }
}

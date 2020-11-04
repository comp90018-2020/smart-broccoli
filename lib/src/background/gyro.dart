import 'dart:async';
import 'dart:developer';

import 'package:sensors/sensors.dart';

class Gyro {
  StreamController<GyroscopeEvent> controller =
      StreamController<GyroscopeEvent>();

  Gyro() {
    try {
      controller.addStream(gyroscopeEvents);
    } catch(e){
      log("Gyro Error" + e ,name: "gryo");
    }
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

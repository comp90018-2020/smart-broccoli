import 'dart:async';

import 'package:light/light.dart';

/// The Luminosity sensor
/// Gets light data
class LightSensor {
  Light _light;
  StreamController<int> controller = StreamController<int>();

  LightSensor() {
    _light = new Light();
    controller.addStream(_light.lightSensorStream);
  }

  close() {
    controller.close();
  }

  Future<int> whenLight() async {
    await for (int value in controller.stream) {
      return value;
    }
    return null;
  }
}

import 'dart:async';
import 'dart:developer';

import 'package:light/light.dart';

/// The Luminosity sensor
/// Gets light data
class LightSensor {
  Light _light;
  StreamController<int> controller = StreamController<int>();

  close() {
    controller.close();
  }

  Future<int> whenLight() async {
    try {
      _light = new Light();
      controller.addStream(_light.lightSensorStream);
    } catch (e) {
      log(e, name: "Light");
    }

    await for (int value in controller.stream) {
      return value;
    }
    return null;
  }
}

import 'dart:async';

import 'package:light/light.dart';

class LightSensor {
  Light _light;
  StreamSubscription _lightStream;
  int lumval = -1;

  void onLightData(int luxValue) async {
    print(luxValue);
    lumval = luxValue;
  }

  void stopListeningLight() {
    _lightStream.cancel();
  }

  Future<void> startListeningLight() async {
    _light = new Light();
    try {
      _lightStream = _light.lightSensorStream.listen(onLightData);
    } on LightException catch (exception) {
      print(exception);
      _lightStream.cancel();
    }
  }
}

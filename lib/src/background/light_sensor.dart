import 'dart:async';

import 'package:light/light.dart';

class LightSensor {
  int _luxString = -1;
  Light _light;
  StreamSubscription _subscription;

  int get luxString => _luxString;

  void onData(int luxValue) async {
    print("Lux value: $luxValue");
      _luxString = luxValue;
  }

  void stopListening() {
    _subscription.cancel();
  }

  Future<void> startListening() {
    _light = new Light();
    try {
      _subscription = _light.lightSensorStream.listen(onData);
    }
    on LightException catch (exception) {
      print(exception);
    }
  }
}

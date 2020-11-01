import 'dart:async';

import 'package:sensors/sensors.dart';

class Gyro {
  List<double> _accelerometerValues;
  List<double> _userAccelerometerValues;
  List<double> _gyroscopeValues;
  List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];

  get accelerometerValues => _accelerometerValues;

  get userAccelerometerValues => _userAccelerometerValues;

  get gyroscopeValues => _gyroscopeValues;

  gyroCancel() {
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  gyro() {
    _streamSubscriptions
        .add(accelerometerEvents.listen((AccelerometerEvent event) {
      _accelerometerValues = <double>[event.x, event.y, event.z];
    }));

    _streamSubscriptions.add(gyroscopeEvents.listen((GyroscopeEvent event) {
      _gyroscopeValues = <double>[event.x, event.y, event.z];
    }));

    _streamSubscriptions
        .add(userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      _userAccelerometerValues = <double>[event.x, event.y, event.z];
    }));
  }
}

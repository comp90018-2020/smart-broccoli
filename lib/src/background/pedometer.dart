import 'package:flutter/material.dart';
import 'dart:async';

import 'package:pedometer/pedometer.dart';

// Note this class isn't currently used
class PedoMeter{
  StreamController<PedestrianStatus> _pedestrianStatusStream;
  String status;

  void onPedestrianStatusChanged(PedestrianStatus event) {
    /// Handle status changed
    status = event.status;
  }

  void closePedo(){
    _pedestrianStatusStream.close();
  }

  void onPedestrianStatusError(error) {
    print("WHY ARE YOU NOT WALKING");
  }

  Future<void> initPedoState() async {
    /// Init streams
    _pedestrianStatusStream.addStream(Pedometer.pedestrianStatusStream);

    _pedestrianStatusStream.stream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);
  }
}
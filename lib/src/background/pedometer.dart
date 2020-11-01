import 'package:flutter/material.dart';
import 'dart:async';

import 'package:pedometer/pedometer.dart';


class PedoMeter{
  Stream<PedestrianStatus> _pedestrianStatusStream;
  String status;

  void onPedestrianStatusChanged(PedestrianStatus event) {
    /// Handle status changed
    status = event.status;
  }

  void onPedestrianStatusError(error) {
    print("WHY ARE YOU NOT WALKING");
  }

  Future<void> initPedoState() async {
    /// Init streams
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;

    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);
  }
}
import 'dart:async';

import 'package:noise_meter/noise_meter.dart';



class Microphone {

  bool _isRecording = false;
  StreamSubscription<NoiseReading> _noiseSubscription;
  NoiseMeter _noiseMeter;
  String recordingData;


  /// decibel data (Nearby noise)
  void onDataRecording(NoiseReading noiseReading) {
    if (!_isRecording) {
      _isRecording = true;
    }
    recordingData = noiseReading.toString();
  }

  void startRecording() async {
    try {
      _noiseSubscription = _noiseMeter.noiseStream.listen(onDataRecording);
    } catch (err) {
      print(err);
    }
  }

  void stopRecording() async {
    try {
      if (_noiseSubscription != null) {
        _noiseSubscription.cancel();
        _noiseSubscription = null;
      }
      _isRecording = false;
    } catch (err) {
      print('stopRecorder error: $err');
    }
  }



}
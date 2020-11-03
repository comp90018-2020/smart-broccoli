import 'dart:async';
import 'dart:developer';

import 'package:noise_meter/noise_meter.dart';

/// Note this class isn't currently used but is here just in case we need it
/// Will be removed in merge
class Microphone {
  bool _isRecording = false;
  StreamSubscription<NoiseReading> _noiseSubscription;
  NoiseMeter _noiseMeter;
  NoiseReading noiseReading;

  Microphone(){
    _noiseMeter = new NoiseMeter();
  }

  Future<double> getReading() async {
    log("Attempting to get reading");
    while (!_isRecording) {}
    log("No reading");
    return noiseReading.meanDecibel;
  }

  void onData(NoiseReading noiseReading) {
    log("isRecording" + _isRecording.toString());
    if (!this._isRecording) {
      _isRecording = true;
    }
    noiseReading = noiseReading;
    log(noiseReading.toString());

  }

  Future<void> start() async {
    try {
      _noiseSubscription = _noiseMeter.noiseStream.listen(onData);
    } catch (err) {
      print(err);
    }
    log("blaghhhhh");
  }

  void stop() async {
    try {
      if (_noiseSubscription != null) {
        _noiseSubscription.cancel();
        _noiseSubscription = null;
      }
      this._isRecording = false;
    } catch (err) {
      print('stopRecorder error: $err');
    }
  }
}

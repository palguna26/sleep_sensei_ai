import 'package:tflite_flutter/tflite_flutter.dart';

class SleepStager {
  Interpreter? _interpreter;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('sleep_stager.tflite');
  }

  /// Predicts sleep stage given a window of sensor data (e.g., accelerometer, heart rate)
  int predict(List<double> sensorWindow) {
    if (_interpreter == null) throw Exception('Model not loaded');
    var input = [sensorWindow];
    var output = List.filled(1, 0).reshape([1, 1]);
    _interpreter!.run(input, output);
    return output[0][0];
  }
} 
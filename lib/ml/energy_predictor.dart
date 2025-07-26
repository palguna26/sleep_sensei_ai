import 'package:tflite_flutter/tflite_flutter.dart';

class EnergyPredictor {
  Interpreter? _interpreter;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('energy_predictor.tflite');
  }

  /// Predicts energy level given input features (e.g., [sleepDebt, hourOfDay, chronotypeIndex, ...])
  double predict(List<double> inputFeatures) {
    if (_interpreter == null) throw Exception('Model not loaded');
    var input = [inputFeatures];
    var output = List.filled(1, 0.0).reshape([1, 1]);
    _interpreter!.run(input, output);
    return output[0][0];
  }
} 
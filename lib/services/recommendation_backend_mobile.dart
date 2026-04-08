import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

class RecommenderBackend {
  tfl.Interpreter? _interpreter;

  Future<void> init() async {
    try {
      _interpreter ??= await tfl.Interpreter.fromAsset('assets/ml/model.tflite');
    } catch (_) {}
  }

  double? score(List<double> features) {
    if (_interpreter == null) return null;
    try {
      final input = [features];
      final output = [List<double>.filled(1, 0.0)];
      _interpreter!.run(input, output);
      return output[0][0];
    } catch (_) {
      return null;
    }
  }
}


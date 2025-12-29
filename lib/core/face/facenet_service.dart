import 'dart:math';
import 'dart:typed_data';

import 'package:tflite_flutter/tflite_flutter.dart';

class FaceNetService {
  static const int inputSize = 160;
  static const int embeddingSize = 128;

  Interpreter? _interpreter;
  bool _loaded = false;

  // ---------------- LOAD MODEL ----------------
  Future<void> loadModel() async {
    if (_loaded) return;

    try {
      _interpreter = await Interpreter.fromAsset(
        'facenet.tflite',
        options: InterpreterOptions()..threads = 4,
      );
      _loaded = true;
      print("✅ FaceNet model loaded");
    } catch (e) {
      print("❌ FaceNet load failed: $e");
      rethrow;
    }
  }

  // ---------------- GET EMBEDDING ----------------
  List<double> getEmbedding(Float32List input) {
    if (!_loaded || _interpreter == null) {
      throw Exception("FaceNet model not loaded");
    }

    final output = List.generate(
      1,
          (_) => List.filled(embeddingSize, 0.0),
    );

    _interpreter!.run(
      input.reshape([1, inputSize, inputSize, 3]),
      output,
    );

    return output.first;
  }

  // ---------------- EUCLIDEAN DISTANCE ----------------
  double calculateDistance(
      List<double> a,
      List<double> b,
      ) {
    double sum = 0;
    for (int i = 0; i < a.length; i++) {
      final diff = a[i] - b[i];
      sum += diff * diff;
    }
    return sqrt(sum);
  }

  // ---------------- DISPOSE ----------------
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _loaded = false;
  }
}

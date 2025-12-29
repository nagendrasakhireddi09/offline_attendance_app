import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class FaceEmbedding {
  Interpreter? _interpreter;
  bool _loaded = false;

  Future<void> loadModel() async {
    try {
      debugPrint("🔄 Loading FaceNet model...");

      _interpreter = await Interpreter.fromAsset("assets/models/facenet.tflite",

        options: InterpreterOptions()..threads = 2,
      );

      _loaded = true;
      debugPrint("✅ FaceNet model loaded successfully");
    } catch (e) {
      debugPrint("❌ FaceNet model load failed: $e");
      rethrow;
    }
  }

  List<double> getEmbedding(Float32List input) {
    if (!_loaded || _interpreter == null) {
      throw Exception("FaceNet model not loaded");
    }

    final output = List.filled(128, 0.0).reshape([1, 128]);
    _interpreter!.run(
      input.reshape([1, 160, 160, 3]),
      output,
    );

    return List<double>.from(output[0]);
  }

  void dispose() {
    _interpreter?.close();
  }
}

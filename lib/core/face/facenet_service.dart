import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class FaceNetService {
  static const int inputSize = 160;
  static const int embeddingSize = 128;

  late Interpreter _interpreter;

  static final FaceNetService instance = FaceNetService._internal();

  FaceNetService._internal();

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset(
      'assets/models/facenet.tflite',
      options: InterpreterOptions()..threads = 4,
    );
  }

  List<double> getEmbedding(img.Image faceImage) {
    final input = _preprocess(faceImage);
    final output = List.generate(
      1,
          (_) => List.filled(embeddingSize, 0.0),
    );

    _interpreter.run(input, output);
    return output.first;
  }

  List<dynamic> _preprocess(img.Image image) {
    final resized = img.copyResize(
      image,
      width: inputSize,
      height: inputSize,
    );

    final buffer = Float32List(inputSize * inputSize * 3);
    int index = 0;

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = resized.getPixel(x, y);

        // ✅ Correct way in image ^4.x
        buffer[index++] = (pixel.r - 128) / 128;
        buffer[index++] = (pixel.g - 128) / 128;
        buffer[index++] = (pixel.b - 128) / 128;
      }
    }

    return buffer.reshape([1, inputSize, inputSize, 3]);
  }


  void dispose() {
    _interpreter.close();
  }
}

import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

Float32List imageToFloat32(File imageFile) {
  final image = img.decodeImage(imageFile.readAsBytesSync())!;
  final resized = img.copyResize(image, width: 112, height: 112);

  final Float32List input = Float32List(112 * 112 * 3);
  int i = 0;

  for (int y = 0; y < 112; y++) {
    for (int x = 0; x < 112; x++) {
      final pixel = resized.getPixel(x, y);
      input[i++] = (pixel.r - 128) / 128;
      input[i++] = (pixel.g - 128) / 128;
      input[i++] = (pixel.b - 128) / 128;
    }
  }
  return input;
}

// import 'dart:io';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
//
// class FaceService {
//   final FaceDetector _faceDetector = FaceDetector(
//     options: FaceDetectorOptions(
//       performanceMode: FaceDetectorMode.accurate,
//       enableLandmarks: false,
//       enableContours: false,
//       enableClassification: false,
//     ),
//   );
//
//   Future<Face?> detectFace(File imageFile) async {
//     final inputImage = InputImage.fromFile(imageFile);
//     final faces = await _faceDetector.processImage(inputImage);
//
//     return faces.isNotEmpty ? faces.first : null;
//   }
//
//   void dispose() {
//     _faceDetector.close();
//   }
// }
import 'dart:io';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

class FaceService {
  final _detector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      enableLandmarks: false,
      enableContours: false,
    ),
  );

  Future<img.Image?> detectAndCrop(File file) async {
    final input = InputImage.fromFile(file);
    final faces = await _detector.processImage(input);

    if (faces.isEmpty) return null;

    final original = img.decodeImage(await file.readAsBytes())!;
    final face = faces.first.boundingBox;

    return img.copyCrop(
      original,
      x: face.left.toInt(),
      y: face.top.toInt(),
      width: face.width.toInt(),
      height: face.height.toInt(),
    );
  }

  void dispose() => _detector.close();
}

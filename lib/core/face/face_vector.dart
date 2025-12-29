import 'dart:math';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// ❌ DO NOT USE (unstable)
List<double> faceToVector1(Face face) {
  final box = face.boundingBox;
  return [
    box.left,
    box.top,
    box.width,
    box.height,
    face.headEulerAngleX ?? 0,
    face.headEulerAngleY ?? 0,
    face.headEulerAngleZ ?? 0,
    face.smilingProbability ?? 0,
    face.leftEyeOpenProbability ?? 0,
    face.rightEyeOpenProbability ?? 0,
  ];
}

/// ✅ USE THIS ONLY (stable + normalized)
List<double> faceToVector(Face face) {
  final box = face.boundingBox;
  final w = box.width;
  final h = box.height;

  return [
    box.left / w,
    box.top / h,
    box.width / w,
    box.height / h,
    (face.headEulerAngleX ?? 0) / 90,
    (face.headEulerAngleY ?? 0) / 90,
    (face.headEulerAngleZ ?? 0) / 90,
  ];
}

/// Average multiple samples (future improvement)
List<double> averageVectors(List<List<double>> vectors) {
  final avg = List<double>.filled(vectors[0].length, 0);

  for (final v in vectors) {
    for (int i = 0; i < v.length; i++) {
      avg[i] += v[i];
    }
  }

  for (int i = 0; i < avg.length; i++) {
    avg[i] /= vectors.length;
  }

  return avg;
}

double euclideanDistance(List<double> a, List<double> b) {
  double sum = 0;
  for (int i = 0; i < a.length; i++) {
    sum += pow(a[i] - b[i], 2);
  }
  return sqrt(sum);
}

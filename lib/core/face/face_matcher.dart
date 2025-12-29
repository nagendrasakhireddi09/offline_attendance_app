// import 'package:flutter/foundation.dart';
// import 'face_vector.dart';
//
// bool isFaceMatched(List<double> stored, List<double> live) {
//   if (stored.length != live.length) return false;
//
//   final d = euclideanDistance(stored, live);
//   debugPrint("🧠 Face distance = $d");
//
//   return d < 0.75; // realistic offline threshold
// }
import 'dart:math';

double cosineSimilarity(List<double> a, List<double> b) {
  double dot = 0, magA = 0, magB = 0;

  for (int i = 0; i < a.length; i++) {
    dot += a[i] * b[i];
    magA += a[i] * a[i];
    magB += b[i] * b[i];
  }

  return dot / (sqrt(magA) * sqrt(magB));
}

bool isFaceMatched(List<double> stored, List<double> live) {
  final similarity = cosineSimilarity(stored, live);
  print("🧠 Face similarity = $similarity");
  return similarity > 0.85; // SAFE threshold
}

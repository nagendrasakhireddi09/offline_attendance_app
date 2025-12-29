import 'dart:math';
import 'package:flutter/material.dart';

double euclideanDistance(List<double> a, List<double> b) {
  double sum = 0;
  for (int i = 0; i < a.length; i++) {
    sum += pow(a[i] - b[i], 2);
  }
  return sqrt(sum);
}

bool isFaceMatched(List<double> stored, List<double> live) {
  final distance = euclideanDistance(stored, live);
  debugPrint("🧠 Face distance = $distance");

  return distance < 1.0; // ✔ good threshold for FaceNet
}

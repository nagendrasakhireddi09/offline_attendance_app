import 'dart:io';
import 'package:geolocator/geolocator.dart';

class LocationService {

  /// Get current location with security checks
  Future<Position> getCurrentLocation() async {

    // 1️⃣ Check location service
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location service disabled");
    }

    // 2️⃣ Check permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permission permanently denied");
    }

    // 3️⃣ Get location
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // 4️⃣ MOCK LOCATION DETECTION (ANDROID)
    if (Platform.isAndroid) {
      if (position.isMocked) {
        throw Exception("Fake GPS detected. Disable mock location.");
      }
    }

    // 5️⃣ Accuracy check (optional but recommended)
    if (position.accuracy > 50) {
      throw Exception("GPS accuracy too low. Try again.");
    }

    return position;
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../../core/db/db_helper.dart';
import '../../core/face/face_service.dart';
import '../../core/face/facenet_service.dart';
import '../../core/face/image_utils.dart';




class MarkAttendanceScreen extends StatefulWidget {
  final int employeeId;

  const MarkAttendanceScreen({
    super.key,
    required this.employeeId,
  });

  @override
  State<MarkAttendanceScreen> createState() =>
      _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  CameraController? _cameraController;
  bool _cameraReady = false;
  bool _processing = false;

  final FaceService _faceService = FaceService();
  final FaceNetService _faceNetService = FaceNetService();

  // ---------------- INIT ----------------
  @override
  void initState() {
    super.initState();
    _initCamera();
    _loadModel();
  }

  Future<void> _loadModel() async {
    await _faceNetService.loadModel();
  }

  // ---------------- CAMERA ----------------
  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final cam = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      cam,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    if (mounted) setState(() => _cameraReady = true);
  }

  // ---------------- MARK ATTENDANCE ----------------
  Future<void> markAttendance() async {
    if (_processing || !_cameraReady) return;

    setState(() => _processing = true);

    try {
      // 1️⃣ Capture image
      final XFile pic = await _cameraController!.takePicture();
      final File imageFile = File(pic.path);

      // 2️⃣ Detect face (ML Kit)
      final face = await _faceService.detectAndCrop(imageFile);
      if (face == null) {
        _show("No face detected ❌");
        return;
      }

      // 3️⃣ Convert image → FaceNet input
      final input = imageToFloat32(imageFile);

      // 4️⃣ Generate LIVE FaceNet embedding
      final List<double> liveEmbedding =
      _faceNetService.getEmbedding(input);

      // 5️⃣ Get employee
      final emp =
      await DBHelper.instance.getEmployeeById(widget.employeeId);

      if (emp == null ||
          emp['faceEmbedding'] == null ||
          emp['faceEmbedding'].toString().isEmpty) {
        _show("Employee face data missing ❌");
        return;
      }

      // 6️⃣ Decode stored FaceNet embedding
      final List<double> storedEmbedding =
      (jsonDecode(emp['faceEmbedding']) as List)
          .map((e) => (e as num).toDouble())
          .toList();

      // 7️⃣ Match FaceNet embeddings
      final double distance =
      _faceNetService.calculateDistance(
          storedEmbedding, liveEmbedding);

      debugPrint("🧠 Face distance = $distance");

      if (distance > 1.0) {
        _show("Face not matched ❌");
        return;
      }

      // 8️⃣ Check duplicate attendance
      final today =
      DateFormat('yyyy-MM-dd').format(DateTime.now());

      final alreadyMarked =
      await DBHelper.instance.isAttendanceMarkedToday(
        widget.employeeId,
        today,
        "IN",
      );

      if (alreadyMarked) {
        _show("Attendance already marked today ⚠️");
        return;
      }

      // 9️⃣ Location validation (GLOBAL locations)
      final Position pos =
      await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final locations =
      await DBHelper.instance.getLocations();

      bool inside = false;
      String locationName = "";

      for (final loc in locations) {
        final double dist = Geolocator.distanceBetween(
          pos.latitude,
          pos.longitude,
          loc['latitude'],
          loc['longitude'],
        );

        if (dist <= loc['radius']) {
          inside = true;
          locationName = loc['name'];
          break;
        }
      }

      if (!inside) {
        _show("Outside allowed location ❌");
        return;
      }

      // 🔟 Save attendance
      final now = DateTime.now();
      await DBHelper.instance.insertAttendance(
        widget.employeeId,
        today,
        DateFormat('HH:mm:ss').format(now),
        locationName,
        imageFile.path,
        "IN",
      );

      _show("Attendance marked successfully ✅");

    } catch (e) {
      _show("Error: $e");
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceService.dispose();
    _faceNetService.dispose();
    super.dispose();
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mark Attendance")),
      body: !_cameraReady
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
              child:
              CameraPreview(_cameraController!)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed:
                _processing ? null : markAttendance,
                child: Text(
                  _processing
                      ? "Processing..."
                      : "Mark Attendance",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

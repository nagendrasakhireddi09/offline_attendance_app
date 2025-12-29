
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../core/db/db_helper.dart';
import '../../core/face/face_service.dart';

import '../../core/face/facenet_service.dart';
import '../../core/face/image_utils.dart';


class RegisterEmployeeScreen extends StatefulWidget {
  const RegisterEmployeeScreen({super.key});

  @override
  State<RegisterEmployeeScreen> createState() =>
      _RegisterEmployeeScreenState();
}

class _RegisterEmployeeScreenState extends State<RegisterEmployeeScreen> {
  final nameCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final designationCtrl = TextEditingController();

  CameraController? _cameraController;
  bool _cameraReady = false;
  bool _modelLoaded = false;
  bool _captured = false;
  bool _saving = false;

  final FaceService _faceService = FaceService();
  final FaceNetService _faceNetService = FaceNetService();

  String? _photoPath;
  String? _faceEmbeddingJson;

  // ---------------- INIT ----------------
  @override
  void initState() {
    super.initState();
    _initCamera();
    _loadFaceModel();
  }

  Future<void> _loadFaceModel() async {
    try {
      await _faceNetService.loadModel();
      if (mounted) {
        setState(() => _modelLoaded = true);
      }
    } catch (e) {
      if (mounted) {
        _msg("Failed to load face recognition model : $e");
      }
    }
  }

  // ---------------- CAMERA ----------------
  Future<void> _initCamera() async {
    final cams = await availableCameras();
    final cam = cams.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cams.first,
    );

    _cameraController = CameraController(
      cam,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    if (mounted) setState(() => _cameraReady = true);
  }

  // ---------------- CAPTURE FACE ----------------
  Future<void> captureFace() async {
    if (!_cameraReady) {
      _msg("Camera not ready");
      return;
    }

    if (!_modelLoaded) {
      _msg("Face recognition model is still loading. Please wait...");
      return;
    }

    try {
      final pic = await _cameraController!.takePicture();
      final file = File(pic.path);

      final face = await _faceService.detectAndCrop(file);
      if (face == null) {
        _msg("No face detected ❌");
        return;
      }

      // Convert image → FaceNet input
      final input = imageToFloat32(file);

      // Generate FaceNet embedding
      final embedding = _faceNetService.getEmbedding(input);

      setState(() {
        _photoPath = file.path;
        _faceEmbeddingJson = jsonEncode(embedding);
        _captured = true;
      });

      _msg("Face captured successfully ✅");
    } catch (e) {
      _msg("Error capturing face: $e");
    }
  }

  // ---------------- SAVE EMPLOYEE ----------------
  Future<void> saveEmployee() async {
    if (_saving) return;

    if (nameCtrl.text.isEmpty ||
        mobileCtrl.text.isEmpty ||
        passCtrl.text.isEmpty ||
        designationCtrl.text.isEmpty ||
        !_captured) {
      _msg("Please fill all fields & capture face");
      return;
    }

    setState(() => _saving = true);

    await DBHelper.instance.insertEmployeeFull(
      name: nameCtrl.text,
      designation: designationCtrl.text,
      mobile: mobileCtrl.text,
      userId: mobileCtrl.text,
      password: passCtrl.text,
      role: "EMPLOYEE",
      faceEmbedding: _faceEmbeddingJson!,
      photoPath: _photoPath!,
    );

    _msg("Employee registered successfully ✅");
    Navigator.pop(context);
  }

  // ---------------- UI HELPERS ----------------
  void _msg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  InputDecoration input(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
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
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Register Employee"),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
            ),
          ),
        ),
      ),
      body: (!_cameraReady || !_modelLoaded)
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                        controller: nameCtrl,
                        decoration:
                        input("Employee Name", Icons.person)),
                    const SizedBox(height: 14),
                    TextField(
                        controller: designationCtrl,
                        decoration:
                        input("Designation", Icons.work)),
                    const SizedBox(height: 14),
                    TextField(
                        controller: mobileCtrl,
                        keyboardType: TextInputType.phone,
                        decoration:
                        input("Mobile Number", Icons.phone)),
                    const SizedBox(height: 14),
                    TextField(
                        controller: passCtrl,
                        obscureText: true,
                        decoration:
                        input("Password", Icons.lock)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  height: 260,
                  width: double.infinity,
                  child: _captured
                      ? Image.file(File(_photoPath!), fit: BoxFit.cover)
                      : CameraPreview(_cameraController!),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _captured
                ? OutlinedButton.icon(
              onPressed: () =>
                  setState(() => _captured = false),
              icon: const Icon(Icons.refresh),
              label: const Text("Retake Face"),
            )
                : ElevatedButton.icon(
              onPressed: (_cameraReady && _modelLoaded) ? captureFace : null,
              icon: const Icon(Icons.camera_alt),
              label: Text(_modelLoaded ? "Capture Face" : "Loading model..."),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : saveEmployee,
                child: Text(
                  _saving ? "Saving..." : "REGISTER EMPLOYEE",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



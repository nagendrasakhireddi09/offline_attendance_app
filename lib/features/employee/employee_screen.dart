import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../../core/db/db_helper.dart';
import '../../core/face/face_embedding.dart';
import '../../core/face/face_service.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  CameraController? _controller;
  bool _cameraReady = false;

  final FaceService _faceService = FaceService();
  final FaceEmbedding _embeddingService = FaceEmbedding();

  @override
  void initState() {
    super.initState();
    _initCamera();
    _embeddingService.loadModel();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      _controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _cameraReady = true;
        });
      }
    } catch (e) {
      debugPrint("Camera init error: $e");
    }
  }

  /// Convert image to Float32List for FaceNet
  Float32List _imageToFloat32(img.Image image) {
    const int inputSize = 160;
    const double mean = 127.5;
    const double std = 127.5;

    final Float32List buffer = Float32List(1 * inputSize * inputSize * 3);
    int index = 0;

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = image.getPixel(x, y);
        buffer[index++] = (img.getLuminance(pixel) - mean) / std;
        buffer[index++] = (img.getLuminance(pixel) - mean) / std;
        buffer[index++] = (img.getLuminance(pixel) - mean) / std;
      }
    }
    return buffer;
  }

  Future<void> registerFace() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final XFile photo = await _controller!.takePicture();
    final File imageFile = File(photo.path);

    final face = await _faceService.detectFace(imageFile);
    if (face == null) {
      _show("No face detected. Try again.");
      return;
    }

    // Decode image
    final img.Image? decoded =
    img.decodeImage(imageFile.readAsBytesSync());

    if (decoded == null) {
      _show("Image processing failed");
      return;
    }

    // Resize to FaceNet input size
    final img.Image resized =
    img.copyResize(decoded, width: 160, height: 160);

    // Convert image to Float32List
    final Float32List input = _imageToFloat32(resized);

    // Generate embedding
    final List<double> embedding =
    _embeddingService.getEmbedding(input);

    // // Save to database (JSON string)
    // await DBHelper.instance.insertEmployee(
    //   "Employee ${DateTime.now().millisecondsSinceEpoch}",
    //   jsonEncode(embedding),
    // );

    _show("Face registered successfully");
  }

  void _show(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _controller?.dispose();
    _faceService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register Employee Face")),
      body: !_cameraReady
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: CameraPreview(_controller!),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: registerFace,
                child: const Text("Register Face"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

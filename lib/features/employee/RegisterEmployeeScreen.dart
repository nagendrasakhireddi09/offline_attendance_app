// import 'dart:convert';
// import 'dart:io';
//
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
//
// import '../../core/db/db_helper.dart';
// import '../../core/face/face_service.dart';
// import '../../core/face/face_vector.dart';
//
// class RegisterEmployeeScreen extends StatefulWidget {
//   const RegisterEmployeeScreen({super.key});
//
//   @override
//   State<RegisterEmployeeScreen> createState() =>
//       _RegisterEmployeeScreenState();
// }
//
// class _RegisterEmployeeScreenState extends State<RegisterEmployeeScreen> {
//   final nameCtrl = TextEditingController();
//   final mobileCtrl = TextEditingController();
//   final passCtrl = TextEditingController();
//   final _designationCtrl = TextEditingController();
//
//
//   CameraController? controller;
//   bool ready = false;
//   bool captured = false;
//
//   final faceService = FaceService();
//
//   String? photoPath;
//   String? faceVector;
//
//   @override
//   void initState() {
//     super.initState();
//     _initCamera();
//   }
//
//   Future<void> _initCamera() async {
//     final cams = await availableCameras();
//     controller = CameraController(
//       cams.first,
//       ResolutionPreset.medium,
//       enableAudio: false,
//     );
//     await controller!.initialize();
//     setState(() => ready = true);
//   }
//
//   Future<void> capture() async {
//     final pic = await controller!.takePicture();
//     final file = File(pic.path);
//
//     final face = await faceService.detectFace(file);
//     if (face == null) {
//       _msg("No face detected");
//       return;
//     }
//
//     final vector = faceToVector(face);
//
//     setState(() {
//       photoPath = file.path;
//       faceVector = jsonEncode(vector);
//       captured = true;
//     });
//
//     _msg("Face captured");
//   }
//
//   Future<void> save() async {
//     if (!captured) {
//       _msg("Capture face first");
//       return;
//     }
//
//     await DBHelper.instance.insertEmployeeFull(
//       name: nameCtrl.text,
//       designation: _designationCtrl.text,
//       mobile: mobileCtrl.text,
//       userId: mobileCtrl.text,
//       password: passCtrl.text,
//       role: "EMPLOYEE",
//       faceEmbedding: faceVector!,
//       photoPath: photoPath!,
//     );
//
//     _msg("Employee registered successfully");
//     Navigator.pop(context);
//   }
//
//   void _msg(String s) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text(s)));
//   }
//
//   @override
//   void dispose() {
//     controller?.dispose();
//     faceService.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Register Employee")),
//       body: !ready
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name")),
//             TextField(controller: _designationCtrl, decoration: const InputDecoration(labelText: "Designation")),
//             TextField(controller: mobileCtrl, decoration: const InputDecoration(labelText: "Mobile")),
//             TextField(controller: passCtrl, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
//             const SizedBox(height: 16),
//
//             SizedBox(
//               height: 220,
//               child: captured
//                   ? Image.file(File(photoPath!), fit: BoxFit.cover)
//                   : CameraPreview(controller!),
//             ),
//
//             const SizedBox(height: 10),
//
//             captured
//                 ? ElevatedButton(
//               onPressed: () => setState(() => captured = false),
//               child: const Text("Retake"),
//             )
//                 : ElevatedButton(
//               onPressed: capture,
//               child: const Text("Capture Face"),
//             ),
//
//             const SizedBox(height: 20),
//             ElevatedButton(onPressed: save, child: const Text("Register"))
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../core/db/db_helper.dart';
import '../../core/face/face_service.dart';
import '../../core/face/face_vector.dart';

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

  CameraController? controller;
  bool ready = false;
  bool captured = false;

  final faceService = FaceService();

  String? photoPath;
  String? faceVector;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cams = await availableCameras();
    controller = CameraController(
      cams.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await controller!.initialize();
    setState(() => ready = true);
  }

  Future<void> capture() async {
    final pic = await controller!.takePicture();
    final file = File(pic.path);

    final face = await faceService.detectFace(file);
    if (face == null) {
      _msg("No face detected");
      return;
    }

    final vector = faceToVector(face);

    setState(() {
      photoPath = file.path;
      faceVector = jsonEncode(vector);
      captured = true;
    });

    _msg("Face captured successfully");
  }

  Future<void> save() async {
    if (!captured) {
      _msg("Please capture face first");
      return;
    }

    await DBHelper.instance.insertEmployeeFull(
      name: nameCtrl.text,
      designation: designationCtrl.text,
      mobile: mobileCtrl.text,
      userId: mobileCtrl.text,
      password: passCtrl.text,
      role: "EMPLOYEE",
      faceEmbedding: faceVector!,
      photoPath: photoPath!,
    );

    _msg("Employee registered successfully");
    Navigator.pop(context);
  }

  void _msg(String s) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(s)));
  }

  @override
  void dispose() {
    controller?.dispose();
    faceService.dispose();
    super.dispose();
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      /// Gradient AppBar
      appBar: AppBar(
        title: const Text("Register Employee"),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF11998E),
                Color(0xFF38EF7D),
              ],
            ),
          ),
        ),
      ),

      body: !ready
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Form Card
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
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

            /// Camera Preview
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  height: 260,
                  width: double.infinity,
                  child: captured
                      ? Image.file(
                    File(photoPath!),
                    fit: BoxFit.cover,
                  )
                      : CameraPreview(controller!),
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// Capture Button
            captured
                ? OutlinedButton.icon(
              onPressed: () =>
                  setState(() => captured = false),
              icon: const Icon(Icons.refresh),
              label: const Text("Retake Face"),
            )
                : ElevatedButton.icon(
              onPressed: capture,
              icon: const Icon(Icons.camera_alt),
              label: const Text("Capture Face"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// Register Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF6A11CB),
                      Color(0xFF2575FC),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ElevatedButton(
                  onPressed: save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "REGISTER EMPLOYEE",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


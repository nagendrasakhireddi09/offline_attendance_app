import 'package:flutter/material.dart';
import '../../core/db/db_helper.dart';

class EditEmployeeScreen extends StatefulWidget {
  final Map<String, dynamic> employee;
  const EditEmployeeScreen({super.key, required this.employee});

  @override
  State<EditEmployeeScreen> createState() => _EditEmployeeScreenState();
}

class _EditEmployeeScreenState extends State<EditEmployeeScreen> {
  late TextEditingController nameCtrl;
  late TextEditingController mobileCtrl;
  late TextEditingController designationCtrl;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.employee['name']);
    mobileCtrl = TextEditingController(text: widget.employee['mobile']);
    designationCtrl =
        TextEditingController(text: widget.employee['designation']);
  }

  Future<void> _save() async {
    await DBHelper.instance.updateEmployee(
      id: widget.employee['id'],
      name: nameCtrl.text,
      mobile: mobileCtrl.text,
      designation: designationCtrl.text,
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Employee")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: mobileCtrl, decoration: const InputDecoration(labelText: "Mobile")),
            TextField(controller: designationCtrl, decoration: const InputDecoration(labelText: "Designation")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _save, child: const Text("Save Changes")),
          ],
        ),
      ),
    );
  }
}

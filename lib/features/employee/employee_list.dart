import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/db/db_helper.dart';
import 'edit_employee_screen.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  List<Map<String, dynamic>> _employees = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    final data = await DBHelper.instance.getEmployees();
    setState(() {
      _employees = data.where((e) => e['role'] == 'EMPLOYEE').toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Employees")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _employees.isEmpty
          ? const Center(child: Text("No employees registered"))
          : ListView.builder(
        itemCount: _employees.length,
        itemBuilder: (context, index) {
          final emp = _employees[index];
          return _employeeCard(emp);
        },
      ),
    );
  }


  Widget _employeeCard(Map<String, dynamic> emp) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: emp['photoPath'] != null &&
              emp['photoPath'].toString().isNotEmpty
              ? FileImage(File(emp['photoPath']))
              : null,
          child: emp['photoPath'] == null
              ? const Icon(Icons.person)
              : null,
        ),
        title: Text(emp['name']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emp['designation'] ?? ''),
            Text("Mobile: ${emp['mobile']}"),
            Text(
              "Registered: ${DateTime.parse(emp['createdAt']).toLocal().toString().split('.')[0]}",
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text("Edit")),
            const PopupMenuItem(value: 'delete', child: Text("Delete")),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _openEdit(emp);
            } else {
              _delete(emp['id']);
            }
          },
        ),
      ),
    );
  }


  void _showEmployeeDetails(Map<String, dynamic> emp) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: emp['photoPath'] != null &&
                    emp['photoPath'].toString().isNotEmpty
                    ? FileImage(File(emp['photoPath']))
                    : null,
                child: emp['photoPath'] == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
              const SizedBox(height: 12),
              Text(
                emp['name'],
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("Mobile: ${emp['mobile']}"),
              Text("User ID: ${emp['userId']}"),
              Text("Password: ${emp['password']}"),
              Text("Role: ${emp['role']}"),
            ],
          ),
        );
      },
    );
  }

  void _openEdit(Map<String, dynamic> emp) async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditEmployeeScreen(employee: emp),
      ),
    );

    if (res == true) _loadEmployees();
  }

  void _delete(int id) async {
    await DBHelper.instance.deleteEmployee(id);
    _loadEmployees();
  }

}

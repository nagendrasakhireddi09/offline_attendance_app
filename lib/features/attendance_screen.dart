import 'package:flutter/material.dart';
import '../../core/db/db_helper.dart';
import '../core/utils/excel_exporter.dart';
import 'attendance/attendance_history_screen.dart';
import 'employee/employee_screen.dart';
import 'attendance/mark_attendance_screen.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Offline Attendance")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EmployeeScreen()),
                );
              },
              child: const Text("Register Employee Face"),
            ),

            ElevatedButton(
              onPressed: () async {
                await DBHelper.instance.insertLocation(
                  "Main Office",
                  17.3850,
                  78.4867,
                  100,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Location Added")),
                );
              },
              child: const Text("Add Location (Test)"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AttendanceHistoryScreen(),
                  ),
                );
              },
              child: const Text("View Attendance History"),
            ),
            ElevatedButton(
              onPressed: () async {
                final file = await ExcelExporter.exportAttendance();

                if (file == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("No data to export")),
                  );
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Excel saved: ${file.path}")),
                );
              },
              child: const Text("Export Attendance (Excel)"),
            ),


            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (_) => const MarkAttendanceScreen()),
            //     );
            //   },
            //   child: const Text("Mark Attendance"),
            // ),

            ElevatedButton(
              onPressed: () async {
                final data = await DBHelper.instance.getEmployees();
                debugPrint(data.toString());
              },
              child: const Text("Print Employees (Console) "),
            ),

          ],
        ),
      ),
    );
  }
}

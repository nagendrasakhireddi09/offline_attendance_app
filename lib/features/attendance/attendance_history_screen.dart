import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/db/db_helper.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  final bool? isAdmin;
  final int? employeeId;

  const AttendanceHistoryScreen({
    super.key,
     this.isAdmin,
    this.employeeId,
  });

  Future<List<Map<String, dynamic>>> _loadData() async {
    if (isAdmin ?? false) {
      return await DBHelper.instance.getAttendance();
    } else {
      return await DBHelper.instance
          .getAttendanceByEmployee(employeeId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance History"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No attendance records"),
            );
          }

          final records = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final item = records[index];

              return FutureBuilder<String>(
                future: DBHelper.instance
                    .getEmployeeName(item['employeeId']),
                builder: (context, nameSnap) {
                  final empName = nameSnap.data ?? "Employee";

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // PHOTO
                          CircleAvatar(
                            radius: 26,
                            backgroundImage: item['photoPath'] != null
                                ? FileImage(File(item['photoPath']))
                                : null,
                            child: item['photoPath'] == null
                                ? const Icon(Icons.person)
                                : null,
                          ),

                          const SizedBox(width: 12),

                          // DETAILS
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  empName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "📅 ${DateFormat('dd MMM yyyy').format(DateTime.parse(item['date']))}",
                                ),
                                Text("⏰ ${item['time']}"),
                                Text("📍 ${item['locationName']}"),
                              ],
                            ),
                          ),

                          // STATUS
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius:
                              BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "PRESENT",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

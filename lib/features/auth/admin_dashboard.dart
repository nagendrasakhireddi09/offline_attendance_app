import 'package:flutter/material.dart';
import 'package:offline_attendance/core/locaation/location_list_screen.dart';

import '../../core/locaation/add_location.dart';
import '../../core/utils/excel_exporter.dart';
import '../attendance/attendance_history_screen.dart';
import '../employee/RegisterEmployeeScreen.dart';
import '../employee/employee_list.dart';
import 'login_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  Widget dashboardCard({
    required String title,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: colors.last.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 42),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      /// Gradient AppBar
      appBar: AppBar(
        elevation: 0,
        title: const Text("Admin Dashboard", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF6A11CB),
                Color(0xFF2575FC),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _showLogoutDialog(context),
          )
        ],
      ),

      body: Column(
        children: [
          /// Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF6A11CB),
                  Color(0xFF2575FC),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome Admin 👋",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Manage employees & attendance",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// Dashboard Cards
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  dashboardCard(
                    title: "Register Employee",
                    icon: Icons.person_add,
                    colors: const [
                      Color(0xFF11998E),
                      Color(0xFF38EF7D),
                    ],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterEmployeeScreen(),
                      ),
                    ),
                  ),
                  dashboardCard(
                    title: "Employee List",
                    icon: Icons.people,
                    colors: const [
                      Color(0xFF56CCF2),
                      Color(0xFF2F80ED),
                    ],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EmployeeListScreen(),
                      ),
                    ),
                  ),
                  dashboardCard(
                    title: "Attendance History",
                    icon: Icons.history,
                    colors: const [
                      Color(0xFFFF512F),
                      Color(0xFFDD2476),
                    ],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AttendanceHistoryScreen(
                          isAdmin: true,
                        ),
                      ),
                    ),
                  ),
                  dashboardCard(
                    title: "Export Excel",
                    icon: Icons.file_download,
                    colors: const [
                      Color(0xFF8E2DE2),
                      Color(0xFF4A00E0),
                    ],
                    onTap: () => ExcelExporter.exportAttendance(),
                  ),
                  dashboardCard(
                    title: "Add Location",
                    icon: Icons.location_city,
                    colors: const [
                      Color(0xFF11998E),
                      Color(0xFF38EF7D),
                    ],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddLocationScreen(),
                      ),
                    ),
                  ),
                  dashboardCard(
                    title: "Location List",
                    icon: Icons.people,
                    colors: const [
                      Color(0xFF56CCF2),
                      Color(0xFF2F80ED),
                    ],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LocationListScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

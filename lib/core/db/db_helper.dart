import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'tables.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._internal();
  static Database? _database;

  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, 'attendance.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(employeeTable);
    await db.execute(locationTable);
    await db.execute(attendanceTable);
    await _createDefaultAdmin(db);
  }

  // ---------------- DEFAULT ADMIN ----------------
  Future<void> _createDefaultAdmin(Database db) async {
    final res = await db.query(
      'employees',
      where: 'role = ?',
      whereArgs: ['ADMIN'],
      limit: 1,
    );

    if (res.isEmpty) {
      await db.insert('employees', {
        'name': 'Admin',
        'mobile': '0000000000',
        'userId': 'admin',
        'password': 'admin123',
        'role': 'ADMIN',
        'faceEmbedding': '',
        'photoPath': '',
      });
    }
  }

  // ---------------- LOGIN ----------------
  Future<Map<String, dynamic>?> loginUser(
      String userId,
      String password,
      ) async {
    final db = await database;

    final result = await db.query(
      'employees',
      where: 'userId = ? AND password = ?',
      whereArgs: [userId, password],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // ---------------- EMPLOYEE ----------------

  Future<int> insertEmployeeFull({
    required String name,
    required String mobile,
    required String userId,
    required String password,
    required String role,
    required String designation,
    required String faceEmbedding,
    required String photoPath,
  })
  async {
    final db = await database;
    return await db.insert('employees', {
      'name': name,
      'mobile': mobile,
      'userId': userId,
      'password': password,
      'designation': designation,
      'role': role,
      'faceEmbedding': faceEmbedding,
      'photoPath': photoPath,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<Map<String, dynamic>?> getEmployeeById(int id) async {
    final db = await database;
    final res = await db.query(
      'employees',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (res.isNotEmpty) return res.first;
    return null;
  }

  Future<String> getEmployeeName(int empId) async {
    final db = await database;
    final res = await db.query(
      'employees',
      where: 'id = ?',
      whereArgs: [empId],
      limit: 1,
    );

    if (res.isNotEmpty) {
      return res.first['name'] as String;
    }
    return "Unknown";
  }

  Future<List<Map<String, dynamic>>> getEmployees() async {
    final db = await database;
    return await db.query('employees');
  }

  Future<int> updateEmployee({
    required int id,
    required String name,
    required String mobile,
    required String designation,
  }) async {
    final db = await database;
    return await db.update(
      'employees',
      {
        'name': name,
        'mobile': mobile,
        'designation': designation,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<int> deleteEmployee(int id) async {
    final db = await database;
    return await db.delete(
      'employees',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  // ---------------- LOCATION ----------------
  Future<int> insertLocation(
      String name,
      double lat,
      double lng,
      double radius,
      ) async {
    final db = await database;
    return await db.insert('locations', {
      'name': name,
      'latitude': lat,
      'longitude': lng,
      'radius': radius,
    });
  }

  Future<List<Map<String, dynamic>>> getLocations() async {
    final db = await database;
    return await db.query('locations');
  }

  // ---------------- ATTENDANCE ----------------
  Future<int> insertAttendance(
      int empId,
      String date,
      String time,
      String location,
      String photoPath,
      String type,
      ) async {
    final db = await database;
    return await db.insert('attendance', {
      'employeeId': empId,
      'date': date,
      'time': time,
      'locationName': location,
      'photoPath': photoPath,
      'type': type,
    });
  }
// ---------- UPDATE LOCATION ----------
  Future<int> updateLocation({
    required int id,
    required String name,
    required double lat,
    required double lng,
    required double radius,
  }) async {
    final db = await database;
    return await db.update(
      'locations',
      {
        'name': name,
        'latitude': lat,
        'longitude': lng,
        'radius': radius,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

// ---------- DELETE LOCATION ----------
  Future<int> deleteLocation(int id) async {
    final db = await database;
    return await db.delete(
      'locations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> isAttendanceMarkedToday(
      int empId,
      String date,
      String type,
      ) async {
    final db = await database;

    final res = await db.query(
      'attendance',
      where: 'employeeId = ? AND date = ? AND type = ?',
      whereArgs: [empId, date, type],
      limit: 1,
    );

    return res.isNotEmpty;
  }



  Future<List<Map<String, dynamic>>> getAttendance() async {
    final db = await database;
    return await db.query(
      'attendance',
      orderBy: 'id DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getAttendanceByEmployee(
      int employeeId,
      ) async {
    final db = await database;
    return await db.query(
      'attendance',
      where: 'employeeId = ?',
      whereArgs: [employeeId],
      orderBy: 'date DESC, time DESC',
    );
  }



}

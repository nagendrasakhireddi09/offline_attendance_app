import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

import '../db/db_helper.dart';

class ExcelExporter {
  static Future<File?> exportAttendance() async {
    try {
      final records = await DBHelper.instance.getAttendance();
      if (records.isEmpty) return null;

      final excel = Excel.createExcel();
      final sheet = excel['Attendance'];

      // Header row
      sheet.appendRow([
        TextCellValue('Employee ID'),
        TextCellValue('Date'),
        TextCellValue('Time'),
        TextCellValue('Location'),
      ]);

      // Data rows
      for (final row in records) {
        sheet.appendRow([
          TextCellValue(row['employeeId'].toString()),
          TextCellValue(row['date']),
          TextCellValue(row['time']),
          TextCellValue(row['locationName']),
        ]);
      }

      final dir = await getApplicationDocumentsDirectory();
      final file = File(
        '${dir.path}/attendance_${DateTime.now().millisecondsSinceEpoch}.xlsx',
      );

      await file.writeAsBytes(excel.encode()!);
      return file;
    } catch (e) {
      return null;
    }
  }
}

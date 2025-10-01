import 'package:flutter/material.dart';
import 'package:hr/data/services/absen_service.dart';
import 'package:hr/data/services/tugas_service.dart';
import 'package:hr/data/services/user_service.dart';

class TechTaskStatusProvider extends ChangeNotifier {
  List<double> target = List.filled(12, 0);
  List<double> attendanceRate = List.filled(12, 0);
  List<double> projectCompletion = List.filled(12, 0);

  Future<void> loadFromDb() async {
    final tasks = await TugasService.fetchTugas();
    final attendances = await AbsenService.fetchAbsensi();
    final employees = await UserService.fetchUsers();

    for (int month = 1; month <= 12; month++) {
      // Filter tugas per bulan
      final monthTasks = tasks.where((t) {
        if (t.tanggalSelesai == null) return false;
        final date = DateTime.parse(t.tanggalSelesai); // parse dari string
        return date.month == month;
      }).toList();

      // Filter absensi per bulan
      final monthAttendance = attendances.where((a) {
        if (a.checkinDate == null) return false;
        final date =
            DateTime.parse(a.checkinDate.toString()); // parse dari string
        return date.month == month;
      }).toList();

      // Target = total tugas
      target[month - 1] = monthTasks.length.toDouble();

      // Attendance rate = hadir / total karyawan
      final hadir = monthAttendance.where((a) => a.status == 'hadir').length;
      attendanceRate[month - 1] =
          employees.isEmpty ? 0 : hadir / employees.length * 100;

      // Project completion = selesai / total tugas bulan itu
      final selesai = monthTasks.where((t) => t.status == 'selesai').length;
      projectCompletion[month - 1] =
          monthTasks.isEmpty ? 0 : selesai / monthTasks.length * 100;
    }

    notifyListeners();
  }
  
}

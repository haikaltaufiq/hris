import 'package:flutter/material.dart';
import 'package:hr/data/models/absen_model.dart';
import 'package:hr/data/services/absen_service.dart';

class AttendanceChartProvider extends ChangeNotifier {
  List<AbsenModel> _rawAbsensi = [];

  int _selectedYear = DateTime.now().year;
  int _totalUser = 0; // TOTAL USER NON ADMIN SUPER

  bool _isLoading = false;
  String? _error;

  int get selectedYear => _selectedYear;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ================= LOAD =================
  Future<void> load({required int totalUser}) async {
    _setLoading(true);
    _error = null;

    try {
      _rawAbsensi = await AbsenService.fetchAbsensi();

      // IMPORTANT:
      // totalUser YANG DIPAKE = user non "admin super"
      final uniqueNonAdminUsers = _rawAbsensi
          .where((a) => !_isAdminSuper(a))
          .map((a) => a.userId)
          .toSet();

      _totalUser = uniqueNonAdminUsers.length;
    } catch (e) {
      _error = e.toString();
    }

    _setLoading(false);
  }

  void setYear(int year) {
    _selectedYear = year;
    notifyListeners();
  }

  // ================= PUBLIC =================
  List<double> get tepatWaktuBulanan =>
      _monthlyPercentage(_AttendanceStatus.tepat);

  List<double> get terlambatBulanan =>
      _monthlyPercentage(_AttendanceStatus.telat);

  List<double> get tidakHadirBulanan =>
      _monthlyPercentage(_AttendanceStatus.absen);

  // ================= CORE =================
  List<double> _monthlyPercentage(_AttendanceStatus type) {
    final List<double> result = List.filled(12, 0);

    if (_totalUser == 0) return result;

    for (int month = 1; month <= 12; month++) {
      final monthData = _rawAbsensi.where((a) {
        if (a.checkinDate == null || a.userId == null) return false;
        if (_isAdminSuper(a)) return false;

        final date = DateTime.tryParse(a.checkinDate!);
        if (date == null) return false;

        if (!_isWorkingDay(date)) return false;

        return date.year == _selectedYear && date.month == month;
      }).toList();

      if (monthData.isEmpty) {
        result[month - 1] = 0;
        continue;
      }

      // day -> userId set (NON ADMIN SUPER)
      final Map<DateTime, Set<int>> dailyUsers = {};
      int tepat = 0;
      int telat = 0;

      for (final a in monthData) {
        final date = DateTime.parse(a.checkinDate!);
        final dayKey = DateTime(date.year, date.month, date.day);

        dailyUsers.putIfAbsent(dayKey, () => <int>{});
        dailyUsers[dayKey]!.add(a.userId!);

        if (a.status == 'Tepat Waktu') tepat++;
        if (a.status == 'Terlambat') telat++;
      }

      final int totalDays = dailyUsers.length;
      final int maxCapacity = totalDays * _totalUser;

      if (maxCapacity == 0) {
        result[month - 1] = 0;
        continue;
      }

      final int hadir = tepat + telat;
      final int absen = maxCapacity - hadir;

      double value;
      switch (type) {
        case _AttendanceStatus.tepat:
          value = tepat.toDouble();
          break;
        case _AttendanceStatus.telat:
          value = telat.toDouble();
          break;
        case _AttendanceStatus.absen:
          value = absen.toDouble();
          break;
      }

      result[month - 1] = (value / maxCapacity) * 100;
    }

    return result;
  }

  // ================= HELPERS =================

  bool _isAdminSuper(AbsenModel a) {
    return a.user?.peran?.namaPeran.toLowerCase() == 'admin super';
  }

  bool _isWorkingDay(DateTime date) {
    if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
      return false;
    }

    if (_isHoliday(date)) return false;

    return true;
  }

  // HARD-CODED FIXED-DATE HOLIDAYS
  bool _isHoliday(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);

    const fixedHolidays = [
      [1, 1], // Tahun Baru
      [5, 1], // Hari Buruh
      [8, 17], // Kemerdekaan
      [12, 25], // Natal
    ];

    return fixedHolidays.any(
      (h) => d.month == h[0] && d.day == h[1],
    );
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

enum _AttendanceStatus { tepat, telat, absen }

class TopAttendanceItem {
  final String name;
  final String department;
  final double presentPercent;
  final double ontimePercent;

  TopAttendanceItem({
    required this.name,
    required this.department,
    required this.presentPercent,
    required this.ontimePercent,
  });
}

class ApprovalRequestItem {
  final String type; // Cuti / Lembur
  final String employee;
  final String date;
  final int id;

  ApprovalRequestItem({
    required this.type,
    required this.employee,
    required this.date,
    required this.id,
  });
}

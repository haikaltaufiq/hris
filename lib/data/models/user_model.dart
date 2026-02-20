import 'package:hr/data/models/departemen_model.dart';
import 'package:hr/data/models/jabatan_model.dart';
import 'package:hr/data/models/peran_model.dart';

class UserModel {
  final int id;
  final String nama;
  final String email;
  final String jenisKelamin;
  final String statusPernikahan;
  final JabatanModel? jabatan;
  final PeranModel? peran;
  final DepartemenModel? departemen;
  final String? gajiPokok;
  final String? npwp;
  final String? bpjsKesehatan;
  final String? bpjsKetenagakerjaan;
  final double? latitude;
  final double? longitude;
  final String? status;
  final DateTime? lastUpdate;
  final int? lastUpdateMinutes;
  final String? lastUpdateHuman;

  UserModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.jenisKelamin,
    required this.statusPernikahan,
    this.jabatan,
    required this.peran,
    required this.departemen,
    this.gajiPokok,
    this.npwp,
    this.bpjsKesehatan,
    this.bpjsKetenagakerjaan,
    this.latitude,
    this.longitude,
    this.status,
    this.lastUpdate,
    this.lastUpdateMinutes,
    this.lastUpdateHuman,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      gajiPokok: json['gaji_per_hari']?.toString(),
      npwp: json['npwp'],
      bpjsKesehatan: json['bpjs_kesehatan'],
      bpjsKetenagakerjaan: json['bpjs_ketenagakerjaan'],
      jenisKelamin: json['jenis_kelamin'] ?? '',
      statusPernikahan: json['status_pernikahan'] ?? '',
      jabatan:
          (json['jabatan'] != null && json['jabatan'] is Map<String, dynamic>)
              ? JabatanModel.fromJson(json['jabatan'])
              : null,
      peran: (json['peran'] != null && json['peran'] is Map<String, dynamic>)
          ? PeranModel.fromJson(json['peran'])
          : PeranModel(id: json['peran_id'] ?? 0, namaPeran: '', fitur: []),
      departemen: (json['departemen'] != null &&
              json['departemen'] is Map<String, dynamic>)
          ? DepartemenModel.fromJson(json['departemen'])
          : DepartemenModel(id: json['departemen_id'] ?? 0, namaDepartemen: ''),
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      status: json['status'],
      lastUpdateMinutes: json['last_update_minutes'] != null
          ? (json['last_update_minutes'] as num).toInt()
          : null,
      lastUpdateHuman: json['last_update_human'],
      lastUpdate: json['last_update'] != null
          ? DateTime.tryParse(json['last_update'])
          : (json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'])
              : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'jenis_kelamin': jenisKelamin,
      'status_pernikahan': statusPernikahan,
      'gaji_per_hari': gajiPokok,
      'npwp': npwp,
      'bpjs_kesehatan': bpjsKesehatan,
      'bpjs_ketenagakerjaan': bpjsKetenagakerjaan,
      'jabatan': jabatan?.toJson(),
      'peran': peran?.toJson(),
      'departemen': departemen?.toJson(),
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'last_update': lastUpdate?.toIso8601String(),
    };
  }

  // ========================================
  // HELPER METHODS UNTUK TRACKING
  // ========================================

  // PATCH untuk UserModel.dart

  bool isGpsActive(bool isServiceRunningLocally) {
    if (latitude == null || longitude == null) return false;

    // Prioritas 1: Pake hitungan menit dari backend kalo ada
    if (lastUpdateMinutes != null) {
      return lastUpdateMinutes! <= 5;
    }

    // Prioritas 2: Itung manual (Raw fallback)
    if (lastUpdate == null) return false;
    final minutesSinceUpdate = DateTime.now().difference(lastUpdate!).inMinutes;

    return minutesSinceUpdate <= 5;
  }

  String get formattedLastUpdate {
    // Kalau backend udah ngasih string "5 menit yang lalu", pake itu aja tapi sanitize
    if (lastUpdateHuman != null && lastUpdateHuman!.isNotEmpty) {
      return _sanitizeHumanTime(lastUpdateHuman!);
    }

    // Fallback itung manual
    if (lastUpdate == null) return 'Tidak ada data';

    final Duration diff = DateTime.now().difference(lastUpdate!);
    if (diff.inSeconds < 60) return 'Baru saja';
    // Gunakan abs() buat jaga-jaga kalo jam HP lebih lambat dari server
    final mins = diff.inMinutes.abs();
    if (mins < 60) return '$mins menit yang lalu';

    return '${diff.inHours.abs()} jam yang lalu';
  }

  /// Get initial nama untuk avatar (huruf pertama)
  String get initial => nama.isNotEmpty ? nama[0].toUpperCase() : '?';

  /// Get first name saja
  String get firstName => nama.split(' ').first;

  /// Format waktu update yang lebih readable
  /// Sanitize dan format string last_update_human dari backend.
  /// Backend mengirim float string seperti "5.2938186 menit yang lalu".
  static String _sanitizeHumanTime(String raw) {
    // Match pola: angka (int atau float) + satuan waktu
    final pattern = RegExp(
      r'^([\d.]+)\s*(detik|menit|jam|hari|minggu|bulan|tahun)\s*(.*)$',
      caseSensitive: false,
    );

    final match = pattern.firstMatch(raw.trim());
    if (match == null) return raw;

    final value = double.tryParse(match.group(1) ?? '');
    final unit = match.group(2) ?? '';
    final suffix = match.group(3) ?? '';

    if (value == null) return raw;

    final rounded = value.round();
    return '$rounded $unit${suffix.isNotEmpty ? ' $suffix' : ''}'.trim();
  }

  /// Status text yang readable
  String statusText(bool isTrackingRunning) {
    if (isGpsActive(isTrackingRunning)) {
      return 'GPS Aktif';
    }
    return 'GPS Tidak Aktif';
  }

  /// Koordinat dalam format string
  String get koordinatString {
    if (latitude == null || longitude == null) return '-';
    return '${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}';
  }

  /// Check apakah user punya koordinat
  bool get hasLocation => latitude != null && longitude != null;
}

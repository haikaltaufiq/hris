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
          : PeranModel(
              id: json['peran_id'] ?? 0,
              namaPeran: '',
              fitur: []),
      departemen: (json['departemen'] != null &&
              json['departemen'] is Map<String, dynamic>)
          ? DepartemenModel.fromJson(json['departemen'])
          : DepartemenModel(
              id: json['departemen_id'] ?? 0,
              namaDepartemen: ''),
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      status: json['status'],
      
      // Ambil data dari backend
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

  /// Check apakah GPS user aktif (berdasarkan status dari backend)
  bool get isGpsActive {
    // Jika ada status dari backend, gunakan itu
    if (status != null) {
      return status == 'aktif';
    }
    
    // Fallback: cek berdasarkan lastUpdate (jika backend tidak kirim status)
    if (latitude == null || longitude == null || lastUpdate == null) {
      return false;
    }

    return DateTime.now().difference(lastUpdate!).inMinutes <= 5;
  }

  /// Get initial nama untuk avatar (huruf pertama)
  String get initial => nama.isNotEmpty ? nama[0].toUpperCase() : '?';

  /// Get first name saja
  String get firstName => nama.split(' ').first;

  /// Format waktu update yang lebih readable
  String get formattedLastUpdate {
    // Prioritaskan data dari backend
    if (lastUpdateHuman != null && lastUpdateHuman!.isNotEmpty) {
      return lastUpdateHuman!;
    }
    
    // Fallback ke perhitungan lokal
    if (lastUpdate == null) return 'Tidak ada data';
    
    try {
      final DateTime now = DateTime.now();
      final Duration diff = now.difference(lastUpdate!);

      if (diff.inMinutes < 1) {
        return 'Baru saja';
      } else if (diff.inMinutes < 60) {
        return '${diff.inMinutes} menit yang lalu';
      } else if (diff.inHours < 24) {
        return '${diff.inHours} jam yang lalu';
      } else {
        return '${diff.inDays} hari yang lalu';
      }
    } catch (e) {
      return 'Tidak ada data';
    }
  }

  /// Status text yang readable
  String get statusText {
    if (isGpsActive) return 'GPS Aktif';
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
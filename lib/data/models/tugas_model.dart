import 'package:hr/data/models/user_model.dart';

class TugasModel {
  final int id;
  final String namaTugas;
  final String tanggalMulai;
  final String tanggalSelesai;
  final int radius;
  final double? tugasLat;
  final double? tugasLng;
  final double? lampiranLat;
  final double? lampiranLng;
  final String? note;
  final String status;
  final bool? terlambat;
  final String? lampiran;
  final UserModel? user;

  TugasModel({
    required this.id,
    required this.namaTugas,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.radius,
    this.tugasLat,
    this.tugasLng,
    this.lampiranLat,
    this.lampiranLng,
    this.note,
    required this.status,
    this.terlambat,
    this.lampiran,
    this.user,
  });

  factory TugasModel.fromJson(Map<String, dynamic> json) {
    return TugasModel(
      id: json['id'] ?? 0,
      namaTugas: json['nama_tugas'] ?? '',
      tanggalMulai: json['tanggal_mulai'] ?? '',
      tanggalSelesai: json['tanggal_selesai'] ?? '',
      radius: json['radius_meter'] ?? 100,
      tugasLat: json['tugas_lat'] != null
          ? double.tryParse(json['tugas_lat'].toString())
          : null,
      tugasLng: json['tugas_lng'] != null
          ? double.tryParse(json['tugas_lng'].toString())
          : null,
      lampiranLat: json['lampiran_lat'] != null
          ? double.tryParse(json['lampiran_lat'].toString())
          : null,
      lampiranLng: json['lampiran_lng'] != null
          ? double.tryParse(json['lampiran_lng'].toString())
          : null,
      note: json['instruksi_tugas'],
      status: json['status'] ?? 'Proses',
      terlambat: json['terlambat'] is int
          ? json['terlambat'] == 1
          : json['terlambat'] ?? false,
      lampiran: json['lampiran'],
      user: (json['user'] is Map<String, dynamic>)
          ? UserModel.fromJson(json['user'])
          : null,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_tugas': namaTugas,
      'tanggal_mulai': tanggalMulai,
      'tanggal_selesai': tanggalSelesai,
      'radius_meter': radius,
      'tugas_lat': tugasLat,
      'tugas_lng': tugasLng,
      'lampiran_lat': lampiranLat,
      'lampiran_lng': lampiranLng,
      'instruksi_tugas': note,
      'status': status,
      'terlambat': terlambat,
      'lampiran': lampiran,
      'user': user?.toJson(),
    };
  }
}

// Extension untuk getter tabel
extension TugasTableGetter on TugasModel {
  String get displayUser => user?.nama ?? '-';
  String get displayNote => note ?? '-';
  String get displayLampiran => lampiran != null ? "Lihat Lampiran" : '-';
  
  String get displayLokasiTugas => (tugasLat != null && tugasLng != null)
      ? "${tugasLat!.toStringAsFixed(5)}, ${tugasLng!.toStringAsFixed(5)}"
      : '-';
  
  String get displayLokasiLampiran => (lampiranLat != null && lampiranLng != null)
      ? "${lampiranLat!.toStringAsFixed(5)}, ${lampiranLng!.toStringAsFixed(5)}"
      : '-';
  
  String get displayTerlambat => (terlambat ?? false) ? "Terlambat" : "Tepat Waktu";
  String get shortTugas =>
      namaTugas.length > 20 ? namaTugas.substring(0, 20) + '...' : namaTugas;
}

import 'package:hr/data/models/user_model.dart';

class TugasModel {
  final int id;
  final String namaTugas;
  final String jamMulai;
  final String tanggalMulai;
  final String tanggalSelesai;
  final String lokasi;
  final String note;
  final String status;
  final UserModel? user;

  TugasModel({
    required this.id,
    required this.namaTugas,
    required this.jamMulai,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.lokasi,
    required this.note,
    required this.status,
    this.user,
  });

  factory TugasModel.fromJson(Map<String, dynamic> json) {
    return TugasModel(
      id: json['id'] ?? 0,
      namaTugas: json['nama_tugas'] ?? '',
      jamMulai: json['jam_mulai'] ?? '',
      tanggalMulai: json['tanggal_mulai'] ?? '',
      tanggalSelesai: json['tanggal_selesai'] ?? '',
      lokasi: json['lokasi'] ?? '',
      note: json['instruksi_tugas'] ?? '',
      status: json['status'] ?? '',
      user: (json['user'] is Map<String, dynamic>)
          ? UserModel.fromJson(json['user'])
          : null,
    );
  }

  String get shortTugas =>
      namaTugas.length > 20 ? '${namaTugas.substring(0, 20)}...' : namaTugas;
}

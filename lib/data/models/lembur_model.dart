import 'dart:ui';

import 'package:hr/core/theme/app_colors.dart';

class LemburModel {
  final int id;
  final int userId;
  final String tanggal;
  final String jamMulai;
  final String jamSelesai;
  final String deskripsi;
  final String status;
  final int approve_step;
  final Map<String, dynamic> user;
  final String keterangan_status;

  LemburModel({
    required this.id,
    required this.userId,
    required this.tanggal,
    required this.jamMulai,
    required this.jamSelesai,
    required this.deskripsi,
    required this.status,
    required this.approve_step,
    required this.user,
    required this.keterangan_status,
  });

  factory LemburModel.fromJson(Map<String, dynamic> json) {
    return LemburModel(
      id: json['id'],
      userId: json['user_id'],
      tanggal: json['tanggal'],
      jamMulai: json['jam_mulai'],
      jamSelesai: json['jam_selesai'],
      deskripsi: json['deskripsi'],
      status: json['status'],
      user: json['user'],
      approve_step: json['approve_step'] is String
          ? int.tryParse(json['approve_step']) ?? 0
          : json['approve_step'] ?? 0,
      keterangan_status: json['keterangan_status'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'tanggal': tanggal,
      'jam_mulai': jamMulai,
      'jam_selesai': jamSelesai,
      'deskripsi': deskripsi,
      'status': status,
      'approve_step': approve_step,
      'user': user,
    };
  }

  /// Semua field yang bisa dicari
  List<String> get searchableFields => [
        user['nama']?.toString() ?? '',
        tanggal,
        jamMulai,
        jamSelesai,
        deskripsi,
        status,
      ];

  String get shortDeskripsi =>
      deskripsi.length > 20 ? '${deskripsi.substring(0, 20)}...' : deskripsi;

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isProses => status.toLowerCase() == 'proses';

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'disetujui':
        return AppColors.green;
      case 'ditolak':
        return AppColors.red;
      default:
        return AppColors.yellow;
    }
  }
}

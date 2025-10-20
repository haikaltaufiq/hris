// ignore_for_file: non_constant_identifier_names

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
  final int approveStep;
  final Map<String, dynamic> user;
  final String keteranganStatus;
  final String catatan_penolakan;

  LemburModel({
    required this.id,
    required this.userId,
    required this.tanggal,
    required this.jamMulai,
    required this.jamSelesai,
    required this.deskripsi,
    required this.status,
    required this.approveStep,
    required this.user,
    required this.keteranganStatus,
    required this.catatan_penolakan,
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
      approveStep: json['approve_step'] is String
          ? int.tryParse(json['approve_step']) ?? 0
          : json['approve_step'] ?? 0,
      keteranganStatus: json['keterangan_status'] ?? {},
      catatan_penolakan: json['catatan_penolakan'] ?? '',
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
      'approve_step': approveStep,
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
  bool get isApproved => status.toLowerCase() == 'disetujui';
  bool get isDitolak => status.toLowerCase() == 'ditolak';

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

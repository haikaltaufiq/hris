// ignore_for_file: non_constant_identifier_names

import 'dart:ui';

import 'package:hr/core/theme.dart';

class CutiModel {
  final int id;
  final int userId;
  final String tipe_cuti;
  final String tanggal_mulai;
  final String tanggal_selesai;
  final String alasan;
  final String keterangan_status;
  late final String status;
  final int approve_step;
  final Map<String, dynamic> user;

  CutiModel({
    required this.id,
    required this.userId,
    required this.tipe_cuti,
    required this.tanggal_mulai,
    required this.tanggal_selesai,
    required this.alasan,
    required this.status,
    required this.approve_step,
    required this.user,
    required this.keterangan_status,
  });

  factory CutiModel.fromJson(Map<String, dynamic> json) {
    return CutiModel(
      id: json['id'],
      userId: json['user_id'],
      tipe_cuti: json['tipe_cuti'],
      tanggal_mulai: json['tanggal_mulai'],
      tanggal_selesai: json['tanggal_selesai'],
      alasan: json['alasan'],
      status: json['status'],
      approve_step: json['approve_step'] is String
          ? int.tryParse(json['approve_step']) ?? 0
          : json['approve_step'] ?? 0,
      user: json['user'] ?? {},
      keterangan_status: json['keterangan_status'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'tipe_cuti': tipe_cuti,
      'tanggal_mulai': tanggal_mulai,
      'tanggal_selesai': tanggal_selesai,
      'alasan': alasan,
      'status': status,
      'approve_step': approve_step,
      'user': user,
    };
  }

//Baca nama user
  String get nama =>
      (user['nama'] ?? user['name'] ?? user['full_name'] ?? '').toString();

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isProses => status.toLowerCase() == 'proses';

//Motong alasan kepanjangan
  String get shortAlasan =>
      alasan.length > 20 ? '${alasan.substring(0, 20)}...' : alasan;

//kondisi warna status
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

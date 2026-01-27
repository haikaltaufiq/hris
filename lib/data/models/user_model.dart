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
  final DateTime? lastUpdate;
  
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
    this.lastUpdate,
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
              fitur: []), // fallback pakai id
      departemen: (json['departemen'] != null &&
              json['departemen'] is Map<String, dynamic>)
          ? DepartemenModel.fromJson(json['departemen'])
          : DepartemenModel(
              id: json['departemen_id'] ?? 0,
              namaDepartemen: ''), // fallback pakai id
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      lastUpdate: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,

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
    };
  }
}

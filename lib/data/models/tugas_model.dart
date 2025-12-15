import 'package:hr/data/models/user_model.dart';
import 'package:intl/intl.dart';

class TugasModel {
  final int id;
  final String namaTugas;
  final String namaLok;
  final String tanggalPenugasan;
  final String batasPenugasan;
  // final int radius;
  // final double? tugasLat;
  // final double? tugasLng;
  final double? lampiranLat;
  final double? lampiranLng;
  final String? note;
  final String status;
  final bool? terlambat;
  final int? menitTerlambat;
  final String? waktuUpload;
  final String? lampiran;
  final UserModel? user;

  TugasModel({
    required this.id,
    required this.namaTugas,
    required this.namaLok,
    required this.tanggalPenugasan,
    required this.batasPenugasan,
    // required this.radius,
    // this.tugasLat,
    // this.tugasLng,
    this.lampiranLat,
    this.lampiranLng,
    this.note,
    required this.status,
    this.terlambat,
    this.menitTerlambat,
    this.waktuUpload,
    this.lampiran,
    this.user,
  });

  factory TugasModel.fromJson(Map<String, dynamic> json) {
    return TugasModel(
      id: json['id'] ?? 0,
      namaTugas: json['nama_tugas'] ?? '',
      namaLok: json['nama_lokasi_penugasan'] ?? '',
      tanggalPenugasan: json['tanggal_penugasan'] ?? '',
      batasPenugasan: json['batas_penugasan'] ?? '',
      // radius: json['radius_meter'] ?? 100,
      // tugasLat: json['tugas_lat'] != null
      //     ? double.tryParse(json['tugas_lat'].toString())
      //     : null,
      // tugasLng: json['tugas_lng'] != null
      //     ? double.tryParse(json['tugas_lng'].toString())
      //     : null,
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
      menitTerlambat: json['menit_terlambat'] != null
          ? int.tryParse(json['menit_terlambat'].toString())
          : null,
      waktuUpload: json['waktu_upload']?.toString(),
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
      'nama_lokasi_penugasan': namaLok,
      'tanggal_penugasan': tanggalPenugasan,
      'batas_penugasan': batasPenugasan,
      // 'radius_meter': radius,
      // 'tugas_lat': tugasLat,
      // 'tugas_lng': tugasLng,
      'lampiran_lat': lampiranLat,
      'lampiran_lng': lampiranLng,
      'instruksi_tugas': note,
      'status': status,
      'terlambat': terlambat,
      'menit_terlambat': menitTerlambat,
      'waktu_upload': waktuUpload,
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

  // String get displayLokasiTugas => (tugasLat != null && tugasLng != null)
  //     ? "${tugasLat!.toStringAsFixed(5)}, ${tugasLng!.toStringAsFixed(5)}"
  //     : '-';

  String get displayLokasiLampiran => (lampiranLat != null &&
          lampiranLng != null)
      ? "${lampiranLat!.toStringAsFixed(5)}, ${lampiranLng!.toStringAsFixed(5)}"
      : '-';

  String get displayTerlambat =>
      (terlambat ?? false) ? "Terlambat" : "Tepat Waktu";

  String get shortTugas =>
      namaTugas.length > 20 ? '${namaTugas.substring(0, 20)}...' : namaTugas;

  String get displayWaktuUpload {
    if (waktuUpload == null) return '-';
    try {
      final dt = DateTime.parse(waktuUpload!).toLocal();
      return DateFormat('HH:mm - dd/MM/yyyy').format(dt);
    } catch (_) {
      return waktuUpload!;
    }
  }

  String get displayMenitTerlambat {
    if (menitTerlambat == null) return '-';
    if (menitTerlambat == 0) return 'Tepat Waktu';
    return '$menitTerlambat menit terlambat';
  }
}

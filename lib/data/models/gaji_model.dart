

import 'package:hr/data/models/potongan_gaji.dart';

class GajiUser {
  final int id;
  final String nama;
  final double gajiPokok;
  final double totalLembur;
  final double totalPotongan;
  final double gajiBersih;
  final List<PotonganGajiModel> potongan;
  String status;
  

  GajiUser({
    required this.id,
    required this.nama,
    required this.gajiPokok,
    required this.totalLembur,
    required this.totalPotongan,
    required this.gajiBersih,
    required this.potongan,
    required this.status
  });

  factory GajiUser.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;

    return GajiUser(
      id: user?['id'] ?? 0,
      nama: user?['nama'] ?? "",
      gajiPokok: double.tryParse(json['gaji_pokok']?.toString() ?? "0") ?? 0.0,
      totalLembur: (json['total_lembur'] as num?)?.toDouble() ?? 0.0,
      totalPotongan: (json['total_potongan'] as num?)?.toDouble() ?? 0.0,
      gajiBersih: (json['gaji_bersih'] as num?)?.toDouble() ?? 0.0,
      potongan: (json['potongan'] as List<dynamic>?)
              ?.map((e) => PotonganGajiModel.fromJson(e))
              .toList() ?? [],
      status: json['status']
    );
  }
}

class PotonganGajiModel {
  final int? id;
  final String namaPotongan;
  final double nominal;

  PotonganGajiModel({
    this.id,
    required this.namaPotongan,
    required this.nominal,
  });

  factory PotonganGajiModel.fromJson(Map<String, dynamic> json) {
    return PotonganGajiModel(
      id: json['id'],
      namaPotongan: json['nama_potongan'],
      nominal: double.tryParse(json['nominal'].toString()) ?? 0.0,
    );
  }
}

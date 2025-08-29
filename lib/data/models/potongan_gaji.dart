class PotonganGajiModel {
  final int? id;
  final String namaPotongan;
  final double nominal;
  final double? nilai;

  PotonganGajiModel({
    this.id,
    required this.namaPotongan,
    required this.nominal,
    this.nilai,
  });

  factory PotonganGajiModel.fromJson(Map<String, dynamic> json) {
    return PotonganGajiModel(
      id: json['id'],
      namaPotongan: json['nama_potongan'],
      nominal: double.tryParse(json['persen'].toString()) ?? 0.0,
      nilai: double.tryParse(json['nilai'].toString()) ?? 0.0,
    );
  }
}

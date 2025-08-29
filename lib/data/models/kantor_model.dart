class KantorModel {
  final int? id;
  final String jamMasuk;
  final int? minimalKeterlambatan;
  final double lat;
  final double lng;
  final int radiusMeter;
  final int jatahCutiTahunan;
  KantorModel({
    this.id,
    required this.jamMasuk,
    required this.minimalKeterlambatan,
    required this.lat,
    required this.lng,
    required this.radiusMeter,
    required this.jatahCutiTahunan,
  });

  factory KantorModel.fromJson(Map<String, dynamic> json) {
    return KantorModel(
        id: json['id'],
        jamMasuk: json['jam_masuk'],
        minimalKeterlambatan: json['minimal_keterlambatan'],
        lat: double.parse(json['lat'].toString()),
        lng: double.parse(json['lng'].toString()),
        radiusMeter: int.parse(json['radius_meter'].toString()),
        jatahCutiTahunan: int.parse(json['jatah_cuti_tahunan'].toString()));
  }

  Map<String, dynamic> toJson() {
    return {
      "jam_masuk": jamMasuk,
      "minimal_keterlambatan": minimalKeterlambatan,
      "lat": lat,
      "lng": lng,
      "radius_meter": radiusMeter,
      "jatah_cuti_tahunan": jatahCutiTahunan,
    };
  }
}

class Fitur {
  final int id;
  final String namaFitur;
  final String deskripsiFitur;

  Fitur({
    required this.id, 
    required this.namaFitur,
    required this.deskripsiFitur,

  });

  factory Fitur.fromJson(Map<String, dynamic> json) {
    return Fitur(
      id: json['id'],
      namaFitur: json['nama_fitur'],
      deskripsiFitur: json['deskripsi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_fitur': namaFitur,
      'deskripsi': deskripsiFitur,
    };
  }
}

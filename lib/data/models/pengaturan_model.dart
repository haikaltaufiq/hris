class Pengaturan {
  final String tema;
  final String bahasa;

  Pengaturan({
    required this.tema, 
    required this.bahasa
  });

  factory Pengaturan.fromJson(Map<String, dynamic> json) {
    return Pengaturan(
      tema: json['tema'],
      bahasa: json['bahasa'],
    );
  }

  Map<String, dynamic> toJson() => {
        'tema': tema,
        'bahasa': bahasa,
      };
}

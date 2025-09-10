import 'package:hr/data/models/fitur_model.dart';

class PeranModel {
  final int id;
  final String namaPeran;
  final List<Fitur> fitur;

  PeranModel({
    required this.id,
    required this.namaPeran,
    required this.fitur,
  });

  factory PeranModel.fromJson(Map<String, dynamic> json) {
    var fiturList = <Fitur>[];
    if (json['fitur'] != null) {
      fiturList = List<Fitur>.from(
        json['fitur'].map((f) => Fitur.fromJson(f)),
      );
    }

    return PeranModel(
      id: json['id'],
      namaPeran: json['nama_peran'],
      fitur: fiturList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_peran': namaPeran,
      'fitur': fitur.map((f) => f.toJson()).toList(),
    };
  }
}

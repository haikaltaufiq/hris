class JabatanModel {
  final int id;
  final String namaJabatan;

  JabatanModel({
    required this.id,
    required this.namaJabatan,
  });

  factory JabatanModel.fromJson(Map<String, dynamic> json) {
    return JabatanModel(
      id: json['id'],
      namaJabatan: json['nama_jabatan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_jabatan': namaJabatan,
    };
  }
}

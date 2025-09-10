class DepartemenModel {
  final int id;
  final String namaDepartemen;

  DepartemenModel({
    required this.id,
    required this.namaDepartemen,
  });

  factory DepartemenModel.fromJson(Map<String, dynamic> json) {
    return DepartemenModel(
      id: json['id'],
      namaDepartemen: json['nama_departemen'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'namaDepartemen': namaDepartemen,
    };
  }
}

class ReminderData {
  final int id;
  final String judul;
  final String deskripsi;
  final String tanggalJatuhTempo;
  final String mengulang;
  final String status;
  final String pic;
  final String sisaHari;
  final String? sisaJam; 
  final String relative;

  ReminderData({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.tanggalJatuhTempo,
    required this.mengulang,
    required this.status,
    required this.pic,
    required this.sisaHari,
    this.sisaJam,
    required this.relative,
  });

  factory ReminderData.fromJson(Map<String, dynamic> json) {
    return ReminderData(
      id: json['id'],
      judul: json['judul'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      tanggalJatuhTempo: json['tanggal_jatuh_tempo'] ?? '',
      mengulang: json['mengulang'] ?? '',
      status: json['status'] ?? 'Pending',
      pic: json['PIC'] ?? '',
      sisaHari: json['sisa_hari'] ?? '',
      sisaJam: json['sisa_jam'], 
      relative: json['relative'] ?? '',
    );
  }
}
class ReminderData {
  final int id;
  final String judul;
  final String deskripsi;
  final String tanggalJatuhTempo;
  final String status;
  final int? picId;        
  final String? picNama;   
  final String? sisaHari;
  final String? sisaJam; 
  final String? relative;

  ReminderData({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.tanggalJatuhTempo,
    required this.status,
    this.picId,
    this.picNama,
    this.sisaHari,
    this.sisaJam,
    this.relative,
  });

  factory ReminderData.fromJson(Map<String, dynamic> json) {
    return ReminderData(
      id: json['id'],
      judul: json['judul'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      tanggalJatuhTempo: json['tanggal_jatuh_tempo'] ?? '',
      status: json['status'] ?? 'Pending',
      // kalau PIC berupa angka
      picId: (json['PIC'] is int) ? json['PIC'] : null,
      // kalau PIC berupa string
      picNama: (json['PIC'] is String) ? json['PIC'] : null,
      sisaHari: json['sisa_hari'] ?? '',
      sisaJam: json['sisa_jam'],
      relative: json['relative'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "judul": judul,
      "deskripsi": deskripsi,
      "tanggal_jatuh_tempo": tanggalJatuhTempo,
      "status": status,
      "peran_id": picId, // saat kirim, selalu kirim ID
    };
  }
}

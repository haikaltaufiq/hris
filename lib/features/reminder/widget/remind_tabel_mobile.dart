import 'package:flutter/material.dart';
import 'package:hr/components/tabel/main_tabel.dart';

class RemindTabelMobile extends StatelessWidget {
  const RemindTabelMobile({super.key});

  final List<String> headers = const [
    'Kategori',
    'Reminder',
    'Jatuh Tempo',
    'Status',
    'Prioritas',
  ];

  @override
  Widget build(BuildContext context) {
    // Dummy data lengkap sesuai web
    final List<List<String>> rows = [
      [
        'Kendaraan',
        'Service Berkala - Service rutin kendaraan setiap 6 bulan',
        '15 Sep 2025',
        'menunggu',
        'Medium',
      ],
      [
        'Kendaraan',
        'Pajak Tahunan - Pembayaran pajak kendaraan bermotor',
        '5 Nov 2025',
        'menunggu',
        'Low',
      ],
      [
        'Kendaraan',
        'Pembaruan Plat Nomor - Ganti plat nomor setelah 5 tahun',
        '12 Mar 2026',
        'menunggu',
        'Low',
      ],
      [
        'Kesehatan',
        'Kontrol Kesehatan - Medical check-up rutin dan pemeriksaan lab',
        '3 Sep 2025',
        'proses',
        'High',
      ],
      [
        'Tagihan',
        'Bayar Listrik - Tagihan bulanan PLN dan air bersih',
        '25 Sep 2025',
        'menunggu',
        'Medium',
      ],
      [
        'Profesional',
        'Perpanjang Sertifikat - Professional certification AWS',
        '20 Oct 2025',
        'menunggu',
        'Medium',
      ],
      [
        'Kendaraan',
        'Asuransi Kendaraan - Perpanjangan polis comprehensive',
        '18 Dec 2025',
        'selesai',
        'Medium',
      ],
      [
        'Tagihan',
        'Bayar Internet - Tagihan bulanan provider internet',
        '30 Sep 2025',
        'menunggu',
        'Low',
      ],
    ];

    return CustomDataTableWidget(
      headers: headers,
      rows: rows,
      statusColumnIndexes: const [3],
      onView: (row) {},
      onDelete: (rows) {},
      onEdit: (row) {},
    );
  }
}

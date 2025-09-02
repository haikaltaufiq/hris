import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/theme/app_colors.dart';

class ReminderTileWeb extends StatefulWidget {
  const ReminderTileWeb({super.key});

  @override
  State<ReminderTileWeb> createState() => _ReminderTileWebState();
}

class _ReminderTileWebState extends State<ReminderTileWeb> {
  // Dummy data hardcoded for reminder table
  final List<String> headers = [
    'Reminder',
    'Kategori',
    'Jatuh Tempo',
    'Status',
    'Prioritas',
  ];

  final List<List<String>> reminderRows = [
    [
      'Service Berkala - Service rutin kendaraan setiap 6 bulan',
      'Kendaraan',
      '15 Sep 2025',
      'menunggu',
      'Medium'
    ],
    [
      'Pajak Tahunan - Pembayaran pajak kendaraan bermotor',
      'Kendaraan',
      '5 Nov 2025',
      'menunggu',
      'Low'
    ],
    [
      'Pembaruan Plat Nomor - Ganti plat nomor setelah 5 tahun',
      'Kendaraan',
      '12 Mar 2026',
      'menunggu',
      'Low'
    ],
    [
      'Kontrol Kesehatan - Medical check-up rutin dan pemeriksaan lab',
      'Kesehatan',
      '3 Sep 2025',
      'proses',
      'High'
    ],
    [
      'Bayar Listrik - Tagihan bulanan PLN dan air bersih',
      'Tagihan',
      '25 Sep 2025',
      'menunggu',
      'Medium'
    ],
    [
      'Perpanjang Sertifikat - Professional certification AWS',
      'Profesional',
      '20 Oct 2025',
      'menunggu',
      'Medium'
    ],
    [
      'Asuransi Kendaraan - Perpanjangan polis comprehensive',
      'Kendaraan',
      '18 Dec 2025',
      'selesai',
      'Medium'
    ],
    [
      'Bayar Internet - Tagihan bulanan provider internet',
      'Tagihan',
      '30 Sep 2025',
      'menunggu',
      'Low'
    ],
  ];

  final List<Map<String, dynamic>> reminderDetails = [
    {
      'description':
          'Periksa oli mesin, filter udara, rem, dan sistem kelistrikan. Termasuk rotasi ban dan pengecekan air radiator.',
      'location': 'Bengkel Resmi Honda - Jl. Sudirman No.123',
      'cost': 'Rp 450.000 - 650.000',
      'daysLeft': 13,
    },
    {
      'description':
          'Perpanjangan STNK dan pembayaran pajak kendaraan bermotor tahunan. Jangan lupa bawa KTP dan STNK asli.',
      'location': 'Samsat Jakarta Barat - Mall Taman Anggrek',
      'cost': 'Rp 1.250.000',
      'daysLeft': 64,
    },
    {
      'description':
          'Penggantian plat nomor setelah masa berlaku 5 tahun habis. Proses bisa dilakukan 30 hari sebelum expired.',
      'location': 'Samsat Keliling atau Samsat terdekat',
      'cost': 'Rp 200.000 - 300.000',
      'daysLeft': 191,
    },
    {
      'description':
          'Pemeriksaan kesehatan komprehensif meliputi cek darah, tekanan darah, kolesterol, dan konsultasi dokter umum.',
      'location': 'RS Siloam Kebon Jeruk - Lantai 3',
      'cost': 'Rp 850.000 (covered by insurance)',
      'daysLeft': 1,
    },
    {
      'description':
          'Pembayaran tagihan listrik bulanan. Bisa bayar melalui mobile banking, ATM, atau datang langsung ke kantor PLN.',
      'location': 'Online Banking / Kantor PLN terdekat',
      'cost': 'Rp 425.000 (estimasi)',
      'daysLeft': 23,
    },
    {
      'description':
          'Renewal sertifikat AWS Solutions Architect. Perlu mengambil exam ulang atau earn continuing education credits.',
      'location': 'Online Proctored Exam / Test Center',
      'cost': 'USD 150 (exam fee)',
      'daysLeft': 48,
    },
    {
      'description':
          'Perpanjangan polis asuransi comprehensive. Perlu submit dokumen dan bayar premi tahunan.',
      'location': 'Kantor Asuransi atau Online',
      'cost': 'Rp 2.500.000',
      'daysLeft': 107,
    },
    {
      'description':
          'Tagihan bulanan provider internet dan TV kabel. Bisa bayar melalui mobile banking atau datang ke outlet.',
      'location': 'Online Banking / Outlet Provider',
      'cost': 'Rp 350.000',
      'daysLeft': 28,
    },
  ];

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
      case 'completed':
        return AppColors.green;
      case 'proses':
      case 'processing':
        return Colors.blue;
      case 'menunggu':
      case 'pending':
        return Colors.orange;
      case 'terlambat':
      case 'overdue':
        return AppColors.red;
      default:
        return Colors.orange;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppColors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return AppColors.green;
      default:
        return Colors.orange;
    }
  }

  String _getDaysLeftText(int daysLeft) {
    if (daysLeft < 0) return '${daysLeft.abs()} hari terlambat';
    if (daysLeft == 0) return 'Hari ini';
    if (daysLeft == 1) return '1 hari lagi';
    return '$daysLeft hari lagi';
  }

  void _handleView(int rowIndex) {
    final detail = reminderDetails[rowIndex];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.secondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Detail Reminder',
            style: TextStyle(
              color: AppColors.putih,
              fontFamily: GoogleFonts.poppins().fontFamily,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deskripsi:',
                  style: TextStyle(
                    color: AppColors.putih,
                    fontWeight: FontWeight.w500,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  detail['description'],
                  style: TextStyle(
                    color: AppColors.putih.withOpacity(0.8),
                    fontFamily: GoogleFonts.poppins().fontFamily,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        color: AppColors.putih.withOpacity(0.6), size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        detail['location'],
                        style: TextStyle(
                          color: AppColors.putih.withOpacity(0.8),
                          fontFamily: GoogleFonts.poppins().fontFamily,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.attach_money, color: AppColors.green, size: 16),
                    SizedBox(width: 8),
                    Text(
                      detail['cost'],
                      style: TextStyle(
                        color: AppColors.green,
                        fontWeight: FontWeight.w500,
                        fontFamily: GoogleFonts.poppins().fontFamily,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.orange, size: 16),
                    SizedBox(width: 8),
                    Text(
                      _getDaysLeftText(detail['daysLeft']),
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                        fontFamily: GoogleFonts.poppins().fontFamily,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Tutup',
                style: TextStyle(
                  color: AppColors.green,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleEdit(int rowIndex) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit reminder ${rowIndex + 1}'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleDelete(int rowIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.secondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Hapus Reminder',
            style: TextStyle(
              color: AppColors.putih,
              fontFamily: GoogleFonts.poppins().fontFamily,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus reminder ini?',
            style: TextStyle(
              color: AppColors.putih.withOpacity(0.8),
              fontFamily: GoogleFonts.poppins().fontFamily,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: AppColors.putih.withOpacity(0.6),
                  fontFamily: GoogleFonts.poppins().fontFamily,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Reminder berhasil dihapus'),
                    backgroundColor: AppColors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Text(
                'Hapus',
                style: TextStyle(
                  color: AppColors.red,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleStatusChanged(int rowIndex, String newStatus) {
    setState(() {
      reminderRows[rowIndex][3] = newStatus;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status berhasil diubah ke $newStatus'),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildStatusCell(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
        color: color.withOpacity(0.1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              fontFamily: GoogleFonts.poppins().fontFamily,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down,
            color: color,
            size: 14,
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityCell(String priority) {
    final color = _getPriorityColor(priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            priority,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              fontFamily: GoogleFonts.poppins().fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(56, 5, 5, 5),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Section
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Text(
          //       'Daftar Pengingat',
          //       style: TextStyle(
          //         fontSize: 24,
          //         fontWeight: FontWeight.w300,
          //         color: AppColors.putih,
          //         fontFamily: GoogleFonts.poppins().fontFamily,
          //         letterSpacing: -0.5,
          //       ),
          //     ),
          //     SizedBox(height: 8),
          //     Text(
          //       '${reminderRows.length} item aktif • ${reminderRows.where((r) => _getStatusColor(r[3]) == Colors.orange || _getStatusColor(r[3]) == AppColors.red).length} mendesak',
          //       style: TextStyle(
          //         fontSize: 14,
          //         color: AppColors.putih.withOpacity(0.6),
          //         fontFamily: GoogleFonts.poppins().fontFamily,
          //       ),
          //     ),
          //   ],
          // ),

          // SizedBox(height: 4),

          // Headers row
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.secondary,
                  width: 2,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                // Headers with custom flex values
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Reminder',
                      style: TextStyle(
                        color: AppColors.putih,
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.poppins().fontFamily,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Kategori',
                      style: TextStyle(
                        color: AppColors.putih,
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.poppins().fontFamily,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Jatuh Tempo',
                      style: TextStyle(
                        color: AppColors.putih,
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.poppins().fontFamily,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Status',
                      style: TextStyle(
                        color: AppColors.putih,
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.poppins().fontFamily,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Prioritas',
                      style: TextStyle(
                        color: AppColors.putih,
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.poppins().fontFamily,
                      ),
                    ),
                  ),
                ),
                // Action header
                SizedBox(
                  width: 120,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "Action",
                      style: TextStyle(
                        color: AppColors.putih,
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.poppins().fontFamily,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Data rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reminderRows.length,
            separatorBuilder: (_, __) => Divider(
              color: AppColors.secondary,
              thickness: 0.5,
              height: 1,
            ),
            itemBuilder: (context, rowIndex) {
              final row = reminderRows[rowIndex];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Reminder column
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Tooltip(
                          message: row[0],
                          waitDuration: const Duration(milliseconds: 300),
                          child: Text(
                            row[0],
                            style: TextStyle(
                              color: AppColors.putih,
                              fontFamily: GoogleFonts.poppins().fontFamily,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ),
                    ),
                    // Category column
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.putih.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            row[1],
                            style: TextStyle(
                              color: AppColors.putih.withOpacity(0.8),
                              fontSize: 12,
                              fontFamily: GoogleFonts.poppins().fontFamily,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Due date column
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              row[2],
                              style: TextStyle(
                                color: AppColors.putih,
                                fontFamily: GoogleFonts.poppins().fontFamily,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              _getDaysLeftText(
                                  reminderDetails[rowIndex]['daysLeft']),
                              style: TextStyle(
                                color: reminderDetails[rowIndex]['daysLeft'] <=
                                        7
                                    ? AppColors.red
                                    : reminderDetails[rowIndex]['daysLeft'] <=
                                            30
                                        ? Colors.orange
                                        : AppColors.green,
                                fontSize: 11,
                                fontFamily: GoogleFonts.poppins().fontFamily,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Status column (dropdown)
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GestureDetector(
                          onTapDown: (TapDownDetails details) async {
                            final RenderBox overlay = Overlay.of(context)
                                .context
                                .findRenderObject() as RenderBox;

                            final selectedStatus = await showMenu<String>(
                              context: context,
                              position: RelativeRect.fromRect(
                                details.globalPosition &
                                    const Size(40, 40), // titik klik
                                Offset.zero & overlay.size, // batas layar
                              ),
                              items: [
                                for (var status in [
                                  'menunggu',
                                  'proses',
                                  'selesai',
                                  'terlambat'
                                ])
                                  PopupMenuItem<String>(
                                    value: status,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(status),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(status),
                                      ],
                                    ),
                                  ),
                              ],
                            );

                            if (selectedStatus != null) {
                              _handleStatusChanged(rowIndex, selectedStatus);
                            }
                          },
                          child: _buildStatusCell(row[3]),
                        ),
                      ),
                    ),
                    // Priority column
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: _buildPriorityCell(row[4]),
                      ),
                    ),
                    // Action buttons
                    SizedBox(
                      width: 120,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Tooltip(
                              message: 'View',
                              child: IconButton(
                                icon: FaIcon(
                                  FontAwesomeIcons.eye,
                                  color: AppColors.putih,
                                  size: 14,
                                ),
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                onPressed: () => _handleView(rowIndex),
                              ),
                            ),
                            Tooltip(
                              message: 'Edit',
                              child: IconButton(
                                icon: FaIcon(
                                  FontAwesomeIcons.pen,
                                  color: AppColors.putih,
                                  size: 14,
                                ),
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                onPressed: () => _handleEdit(rowIndex),
                              ),
                            ),
                            Tooltip(
                              message: 'Delete',
                              child: IconButton(
                                icon: FaIcon(
                                  FontAwesomeIcons.trash,
                                  color: AppColors.putih,
                                  size: 14,
                                ),
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                onPressed: () => _handleDelete(rowIndex),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

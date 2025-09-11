import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/loading.dart';
import 'package:hr/components/tabel/main_tabel.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/data/models/pengingat_model.dart';
import 'package:hr/features/reminder/reminder_viewmodels.dart';
import 'package:hr/routes/app_routes.dart';
import 'package:provider/provider.dart';

class RemindTabelMobile extends StatefulWidget {
  const RemindTabelMobile({super.key});

  @override
  State<RemindTabelMobile> createState() => _RemindTabelMobileState();
}

class _RemindTabelMobileState extends State<RemindTabelMobile> {
  final List<String> headers = const [
    'PIC',
    'Reminder',
    'Jatuh Tempo',
    'Sisa Hari',
    'Status',
  ];

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
      case 'completed':
        return AppColors.green;
      case 'proses':
      case 'processing':
        return Colors.blue;
      case 'pending':
      case 'menunggu':
        return Colors.orange;
      case 'terlambat':
      case 'overdue':
        return AppColors.red;
      default:
        return Colors.orange;
    }
  }

  // Format tanggal untuk tampilan yang lebih baik

  // Function untuk mendapatkan warna berdasarkan waktu tersisa

  void _handleView(ReminderData reminder) {
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
                // Judul
                Text(
                  'Judul:',
                  style: TextStyle(
                    color: AppColors.putih,
                    fontWeight: FontWeight.w500,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  reminder.judul,
                  style: TextStyle(
                    color: AppColors.putih.withOpacity(0.8),
                    fontFamily: GoogleFonts.poppins().fontFamily,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 16),

                // Deskripsi
                Text(
                  'Deskripsi:',
                  style: TextStyle(
                    color: AppColors.putih,
                    fontWeight: FontWeight.w500,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  reminder.deskripsi,
                  style: TextStyle(
                    color: AppColors.putih.withOpacity(0.8),
                    fontFamily: GoogleFonts.poppins().fontFamily,
                  ),
                ),
                SizedBox(height: 16),

                // PIC
                Row(
                  children: [
                    Icon(Icons.person, color: Colors.blue, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'PIC: ${reminder.picNama}',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                        fontFamily: GoogleFonts.poppins().fontFamily,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Jatuh Tempo
                Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.orange, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Jatuh Tempo: ${reminder.tanggalJatuhTempo}',
                      style: TextStyle(
                        color: AppColors.putih.withOpacity(0.8),
                        fontFamily: GoogleFonts.poppins().fontFamily,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Status
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getStatusColor(reminder.status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Status: ${reminder.status}',
                      style: TextStyle(
                        color: _getStatusColor(reminder.status),
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

  @override
  Widget build(BuildContext context) {
    return Consumer<PengingatViewModel>(
      builder: (context, viewModel, child) {
        final displayList = viewModel.searchQuery.isEmpty
            ? viewModel.pengingatList
            : viewModel.filteredList;
        if (viewModel.isLoading) {
          return const Center(child: LoadingWidget());
        }

        final reminders = displayList;
        if (reminders.isEmpty) {
          return Center(
            child: Text(
              'Belum ada reminder',
              style: TextStyle(color: AppColors.putih),
            ),
          );
        }
        final rows = reminders.map((reminder) {
          return [
            reminder.picNama ?? '-',
            reminder.judul,
            reminder.tanggalJatuhTempo,
            reminder.sisaHari ?? '-',
            reminder.status,
          ];
        }).toList();

        return CustomDataTableWidget(
          headers: headers,
          rows: rows,
          statusColumnIndexes: const [4], // kolom status
          onView: (rowIndex) {
            final reminder = reminders[rowIndex];
            _handleView(reminder);
          },
          onDelete: (rowIndex) async {
            final reminder = reminders[rowIndex];
            await viewModel.deletePengingat(reminder.id);
          },
          onEdit: (rowIndex) async {
            final reminder = reminders[rowIndex];
            final result = await Navigator.pushNamed(
              context,
              AppRoutes.reminderEdit,
              arguments: reminder,
            );
            if (result == true) {
              context.read<PengingatViewModel>().fetchPengingat();
            }
          },
        );
      },
    );
  }
}

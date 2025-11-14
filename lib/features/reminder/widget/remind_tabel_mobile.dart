import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/loading.dart';
import 'package:hr/components/dialog/show_confirmation.dart';
import 'package:hr/components/tabel/main_tabel.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
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
            context.isIndonesian ? 'Detail Pengingat' : 'Reminder Details',
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
                  context.isIndonesian ? 'Judul:' : 'Title:',
                  style: TextStyle(
                    color: AppColors.putih,
                    fontWeight: FontWeight.w500,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reminder.judul,
                  style: TextStyle(
                    color: AppColors.putih.withOpacity(0.8),
                    fontFamily: GoogleFonts.poppins().fontFamily,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  context.isIndonesian ? 'Deskripsi:' : 'Description:',
                  style: TextStyle(
                    color: AppColors.putih,
                    fontWeight: FontWeight.w500,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reminder.deskripsi,
                  style: TextStyle(
                    color: AppColors.putih.withOpacity(0.8),
                    fontFamily: GoogleFonts.poppins().fontFamily,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.blue, size: 16),
                    const SizedBox(width: 8),
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.schedule, color: Colors.orange, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      context.isIndonesian
                          ? 'Jatuh Tempo: ${reminder.tanggalJatuhTempo}'
                          : 'Deadline: ${reminder.tanggalJatuhTempo}',
                      style: TextStyle(
                        color: AppColors.putih.withOpacity(0.8),
                        fontFamily: GoogleFonts.poppins().fontFamily,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
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
                    const SizedBox(width: 8),
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
                context.isIndonesian ? 'Tutup' : 'Close',
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
    final List<String> headers = context.isIndonesian
        ? ['PIC', 'Pengingat', 'Jatuh Tempo', 'Sisa Hari', 'Status']
        : ['PIC', 'Reminder', 'Deadline', "Day's Left", 'Status'];

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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 48,
                  color: AppColors.putih.withOpacity(0.7),
                ),
                const SizedBox(height: 8),
                Text(
                  context.isIndonesian
                      ? 'Belum ada pengingat'
                      : 'No reminder available',
                  style: TextStyle(
                    color: AppColors.putih,
                    fontSize: 16,
                  ),
                ),
              ],
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
          dropdownStatusColumnIndexes: const [4],
          statusOptions: const ['Pending', 'Selesai'],
          onStatusChanged: (rowIndex, newStatus) async {
            final reminder = reminders[rowIndex];
            await viewModel.updateStatus(reminder.id, newStatus);
          },
          onView: (rowIndex) {
            final reminder = reminders[rowIndex];
            _handleView(reminder);
          },
          onDelete: (rowIndex) async {
            final confirmed = await showConfirmationDialog(
              context,
              title: context.isIndonesian
                  ? "Konfirmasi Hapus"
                  : "Delete Confirmation",
              content: context.isIndonesian
                  ? "Apakah Anda yakin ingin menghapus pengingat ini?"
                  : "Are you sure you want to delete this reminder?",
              confirmText: context.isIndonesian ? "Hapus" : "Delete",
              cancelText: context.isIndonesian ? "Batal" : "Cancel",
              confirmColor: AppColors.red,
            );
            if (confirmed) {
              final reminder = reminders[rowIndex];
              await viewModel.deletePengingat(reminder.id);
            }
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

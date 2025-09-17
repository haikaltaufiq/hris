// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/const/app_size.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/data/models/pengingat_model.dart';
import 'package:hr/features/reminder/reminder_viewmodels.dart';
import 'package:hr/routes/app_routes.dart';
import 'package:provider/provider.dart';

class ReminderTileWeb extends StatefulWidget {
  const ReminderTileWeb({super.key});

  @override
  State<ReminderTileWeb> createState() => _ReminderTileWebState();
}

class _ReminderTileWebState extends State<ReminderTileWeb> {
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
  String _formatDate(String dateTime) {
    try {
      final parts = dateTime.split(' ');
      if (parts.length >= 1) {
        return parts[0]; // Ambil bagian tanggal saja (grey)
      }
      return dateTime;
    } catch (e) {
      return dateTime;
    }
  }

  // Function untuk mendapatkan warna berdasarkan waktu tersisa
  Color _getTimeRemainingColor(String sisaHari, String relative) {
    final regex = RegExp(r'(\d+)');
    final match = regex.firstMatch(sisaHari);
    final days = match != null ? int.parse(match.group(1)!) : 0;
    // Untuk yang sudah lewat/terlambat
    if (sisaHari.toLowerCase().contains('yang lalu') || days < 1) {
      return AppColors.red; // Terlambat
    } else if (days <= 3) {
      return AppColors.red; // Dekat
    } else if (days <= 7) {
      return Colors.orange; // Sedikit lama
    } else {
      return AppColors.green; // Masih lama
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

  void _handleDelete(ReminderData reminder) {
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
            'Apakah Anda yakin ingin menghapus reminder "${reminder.judul}"?',
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
              onPressed: () async {
                await context
                    .read<PengingatViewModel>()
                    .deletePengingat(reminder.id);
                if (mounted) {
                  NotificationHelper.showTopNotification(
                    context,
                    'Reminder berhasil dihapus',
                    isSuccess: true,
                  );
                }
                Navigator.of(context).pop();
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

  Widget _buildStatusCell(String status, int reminderId) {
    final color = _getStatusColor(status);
    return GestureDetector(
      onTapDown: (TapDownDetails details) async {
        final RenderBox overlay =
            Overlay.of(context).context.findRenderObject() as RenderBox;

        final selectedStatus = await showMenu<String>(
          context: context,
          position: RelativeRect.fromRect(
            details.globalPosition & const Size(40, 40),
            Offset.zero & overlay.size,
          ),
          items: [
            for (var statusOption in ['Pending', 'Selesai'])
              PopupMenuItem<String>(
                value: statusOption,
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getStatusColor(statusOption),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(statusOption),
                  ],
                ),
              ),
          ],
        );

        if (selectedStatus != null && selectedStatus != status) {
          await context
              .read<PengingatViewModel>()
              .updateStatus(reminderId, selectedStatus);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingS, vertical: AppSizes.paddingS),
        alignment: Alignment.center,
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
            Flexible(
              child: Text(
                status,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PengingatViewModel>(builder: (context, viewModel, child) {
      final displayList = viewModel.searchQuery.isEmpty
          ? viewModel.pengingatList
          : viewModel.filteredList;
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
            // Header dengan refresh button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daftar Pengingat',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.putih,
                        fontFamily: GoogleFonts.poppins().fontFamily,
                      ),
                    ),
                    if (!viewModel.isLoading)
                      Text(
                        viewModel.searchQuery.isEmpty
                            ? '${viewModel.pengingatList.length} item total'
                            : '${viewModel.filteredList.length} dari ${viewModel.pengingatList.length} item',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.putih.withOpacity(0.6),
                          fontFamily: GoogleFonts.poppins().fontFamily,
                        ),
                      ),
                  ],
                ),
                IconButton(
                  onPressed: () => viewModel.fetchPengingat(),
                  icon: Icon(
                    Icons.refresh,
                    color: AppColors.putih,
                  ),
                  tooltip: 'Refresh Data',
                ),
              ],
            ),
            SizedBox(height: 16),

            // Loading atau Error State
            if (viewModel.isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.putih),
                  ),
                ),
              )
            else if (displayList.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        color: AppColors.putih.withOpacity(0.6),
                        size: 48,
                      ),
                      SizedBox(height: 16),
                      Text(
                        viewModel.searchQuery.isEmpty
                            ? 'Tidak ada data pengingat'
                            : 'Tidak ada hasil untuk "${viewModel.searchQuery}"',
                        style: TextStyle(
                          color: AppColors.putih.withOpacity(0.6),
                          fontFamily: GoogleFonts.poppins().fontFamily,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              )
            else if (displayList.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        color: AppColors.putih.withOpacity(0.6),
                        size: 48,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Tidak ada data pengingat',
                        style: TextStyle(
                          color: AppColors.putih.withOpacity(0.6),
                          fontFamily: GoogleFonts.poppins().fontFamily,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
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
                    // Reminder column
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
                    // PIC column
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'PIC',
                          style: TextStyle(
                            color: AppColors.putih,
                            fontWeight: FontWeight.bold,
                            fontFamily: GoogleFonts.poppins().fontFamily,
                          ),
                        ),
                      ),
                    ),
                    // Pengulangan column

                    // tanggal column
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'Tanggal',
                          style: TextStyle(
                            color: AppColors.putih,
                            fontWeight: FontWeight.bold,
                            fontFamily: GoogleFonts.poppins().fontFamily,
                          ),
                        ),
                      ),
                    ),
                    // Status column
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
                    // Action column
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
                itemCount: displayList.length,
                separatorBuilder: (_, __) => Divider(
                  color: AppColors.secondary,
                  thickness: 0.5,
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  final reminder = displayList[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Reminder column
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  reminder.judul,
                                  style: TextStyle(
                                    color: AppColors.putih,
                                    fontWeight: FontWeight.w600,
                                    fontFamily:
                                        GoogleFonts.poppins().fontFamily,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                if (reminder.deskripsi.isNotEmpty)
                                  Text(
                                    reminder.deskripsi,
                                    style: TextStyle(
                                      color: AppColors.putih.withOpacity(0.7),
                                      fontSize: 12,
                                      fontFamily:
                                          GoogleFonts.poppins().fontFamily,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                              ],
                            ),
                          ),
                        ),

                        // PIC column
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Colors.blue.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.person,
                                    color: Colors.blue,
                                    size: 12,
                                  ),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      reminder.picNama?.toString() ?? "-",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        fontFamily:
                                            GoogleFonts.poppins().fontFamily,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Jatuh Tempo column
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatDate(reminder.tanggalJatuhTempo),
                                  style: TextStyle(
                                    color: AppColors.putih,
                                    fontFamily:
                                        GoogleFonts.poppins().fontFamily,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  reminder.sisaHari ?? "-",
                                  style: TextStyle(
                                    color: _getTimeRemainingColor(
                                        reminder.sisaHari ?? "-",
                                        reminder.relative ?? "-"),
                                    fontSize: 11,
                                    fontFamily:
                                        GoogleFonts.poppins().fontFamily,
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child:
                                _buildStatusCell(reminder.status, reminder.id),
                          ),
                        ),

                        // Action buttons
                        SizedBox(
                          width: 120,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
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
                                    onPressed: () => _handleView(reminder),
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
                                    onPressed: () async {
                                      final result = await Navigator.pushNamed(
                                        context,
                                        AppRoutes.reminderEdit,
                                        arguments: reminder,
                                      );

                                      if (result == true) {
                                        // panggil provider untuk refresh
                                        context
                                            .read<PengingatViewModel>()
                                            .fetchPengingat();
                                      }
                                    },
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
                                    onPressed: () => _handleDelete(reminder),
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
          ],
        ),
      );
    });
  }
}

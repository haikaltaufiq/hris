import 'package:flutter/material.dart';
import 'package:hr/components/dialog/detail_item.dart';
import 'package:hr/components/dialog/show_confirmation.dart';
import 'package:hr/components/tabel/web_tabel.dart';
import 'package:hr/core/helpers/feature_guard.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/data/api/api_config.dart';
import 'package:hr/data/models/tugas_model.dart';
import 'package:hr/features/task/task_viewmodel/tugas_provider.dart';
import 'package:hr/features/task/tugas_form/form_user_edit.dart';
import 'package:hr/features/task/widgets/lampiran.dart';
import 'package:hr/routes/app_routes.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/helpers/notification_helper.dart';
import '../../../core/theme/app_colors.dart';

class TugasTabelWeb extends StatefulWidget {
  final List<TugasModel> tugasList;
  final VoidCallback? onActionDone;
  const TugasTabelWeb({
    super.key,
    required this.tugasList,
    required this.onActionDone,
  });

  @override
  State<TugasTabelWeb> createState() => _TugasTabelWebState();
}

// clear string dari api
String getFullUrl(String lampiranPath) {
  final cleaned = lampiranPath.replaceAll('\\', '');
  final fullUrl = cleaned.startsWith('http')
      ? cleaned
      : "${ApiConfig.baseUrl}${cleaned.startsWith('/') ? '' : '/'}$cleaned";

  // debugPrint("🧾 Full URL dipakai Flutter: $fullUrl"); // <--- tambahin ini
  return fullUrl;
}

class _TugasTabelWebState extends State<TugasTabelWeb> {
  String parseTime(String? time) {
    if (time == null || time.isEmpty) return '';
    try {
      return DateFormat('HH:mm').format(DateFormat('HH:mm:ss').parse(time));
    } catch (_) {
      return '';
    }
  }

  String parseDate(String? date) {
    if (date == null || date.isEmpty) return '';
    try {
      final parsed = DateTime.parse(date);
      return DateFormat('HH:mm \'-\' dd/MM/yyyy').format(parsed);
    } catch (_) {
      return date;
    }
  }

  Future<void> _editTugas(BuildContext context, int row) async {
    final tugas = widget.tugasList[row];
    final canAccess = await FeatureAccess.has("tambah_tugas");

    if (canAccess) {
      await Navigator.pushNamed(
        context,
        AppRoutes.taskEdit,
        arguments: tugas,
      );
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FormUserEdit(tugas: tugas),
        ),
      );
    }

    widget.onActionDone?.call();
  }

  Future<void> _deleteTugas(BuildContext context, TugasModel tugas) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: "Konfirmasi Hapus",
      content: "Apakah Anda yakin ingin menghapus tugas ini?",
      confirmText: "Hapus",
      cancelText: "Batal",
      confirmColor: AppColors.red,
    );

    if (confirmed) {
      final message = await context.read<TugasProvider>().deleteTugas(tugas.id);
      NotificationHelper.showTopNotification(
        context,
        message ?? 'Gagal menghapus tugas',
        isSuccess: message != null,
      );
    }
    widget.onActionDone?.call();
  }

  // lampiran
  void _showLampiranDialog(BuildContext context, TugasModel tugas) {
    if (tugas.lampiran == null) {
      NotificationHelper.showTopNotification(
        context,
        "Tidak ada lampiran untuk tugas ini",
        isSuccess: false,
      );
      return;
    }

    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 16 : 40,
          vertical: isSmallScreen ? 24 : 40,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 800,
            maxHeight: screenSize.height * 0.8,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.putih.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.attach_file_rounded,
                      color: AppColors.putih,
                      size: isSmallScreen ? 20 : 24,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Lampiran Tugas',
                        style: GoogleFonts.poppins(
                          color: AppColors.putih,
                          fontWeight: FontWeight.w600,
                          fontSize: isSmallScreen ? 16 : 18,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppColors.putih,
                        size: isSmallScreen ? 20 : 24,
                      ),
                      tooltip: 'Tutup',
                    ),
                  ],
                ),
              ),
              // Content
              Flexible(
                child: Container(
                  padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                  child: ProfessionalLampiranWidget(
                      url: getFullUrl(tugas.lampiran!)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLampiranWidget(String url) {
    return ProfessionalLampiranWidget(url: url);
  }

  void _showDetailDialog(BuildContext context, TugasModel tugas) {
    Color statusColor;
    switch (tugas.status.toLowerCase()) {
      case 'selesai':
        statusColor = Colors.green;
        break;
      case 'proses':
        statusColor = Colors.orange;
        break;
      case 'ditolak':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'Detail Tugas',
          style: GoogleFonts.poppins(
            color: AppColors.putih,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DetailItem(
              label: 'Kepada',
              value: tugas.user?.nama ?? '-',
            ),
            SizedBox(height: 5),
            DetailItem(
              label: 'Judul',
              value: tugas.namaTugas,
            ),
            SizedBox(height: 5),
            DetailItem(
              label: 'Tanggal Mulai',
              value: parseDate(tugas.tanggalPenugasan),
            ),
            SizedBox(height: 5),
            DetailItem(
              label: 'Batas Submit',
              value: parseDate(tugas.batasPenugasan),
            ),
            SizedBox(height: 5),
            DetailItem(
              label: 'Note',
              value: tugas.note ?? '-',
            ),
            SizedBox(height: 5),
            DetailItem(
              label: 'Status',
              value: tugas.status,
              color: statusColor,
            ),
            SizedBox(height: 5),
            DetailItem(
              label: 'Ketepatan',
              value: tugas.displayTerlambat,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Tutup',
              style: GoogleFonts.poppins(
                color: AppColors.putih,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openMap(String latlongStr) {
    try {
      final parts = latlongStr.split(',');
      final lat = double.parse(parts[0].trim());
      final lng = double.parse(parts[1].trim());

      Navigator.pushNamed(
        context,
        AppRoutes.mapPage,
        arguments: LatLng(lat, lng),
      );
    } catch (_) {
      NotificationHelper.showTopNotification(
        context,
        "Format lokasi tidak valid",
        isSuccess: false,
      );
    }
  }

  String _hitungSisaWaktu(String? batas) {
    if (batas == null) return "-";
    try {
      final deadline = DateTime.parse(batas);
      final now = DateTime.now();
      final diff = deadline.difference(now);

      if (diff.isNegative) {
        return "Lewat ${diff.inMinutes.abs()} menit";
      } else {
        final jam = diff.inHours;
        final menit = diff.inMinutes.remainder(60);
        return "$jam jam $menit menit lagi";
      }
    } catch (_) {
      return "-";
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> headers = context.isIndonesian
        ? [
            "Kepada",
            "Judul",
            "Mulai",
            "Batas Submit",
            "Radius Lokasi",
            "Lokasi Tugas",
            "Lokasi Lampiran",
            "Status",
            "Catatan",
            "Lampiran",
            "Waktu Upload",
            "Keterlambatan",
            "Sisa Waktu",
            "Ketepatan"
          ]
        : [
            "To",
            "Title",
            "Start",
            "Deadline",
            "Location Radius",
            "Task Location",
            "Attachment Location",
            "Status",
            "Note",
            "Attachment",
            "Upload Time",
            "Delay",
            "Remaining Time",
            "Punctuality"
          ];
    final rows = widget.tugasList.map((tugas) {
      return [
        tugas.displayUser,
        tugas.shortTugas,
        parseDate(tugas.tanggalPenugasan),
        parseDate(tugas.batasPenugasan),
        "${tugas.radius} M",
        tugas.displayLokasiTugas != null && tugas.displayLokasiTugas != "-"
            ? context.isIndonesian
                ? "Lihat Lokasi"
                : "See Location"
            : '-',
        tugas.displayLokasiLampiran != null &&
                tugas.displayLokasiLampiran != "-"
            ? context.isIndonesian
                ? "Lihat Lokasi"
                : "See Location"
            : '-',
        tugas.status,
        tugas.displayNote,
        tugas.displayLampiran,
        tugas.displayWaktuUpload,
        tugas.menitTerlambat != null
            ? context.isIndonesian
                ? "${tugas.menitTerlambat} menit"
                : "${tugas.menitTerlambat} minute"
            : (tugas.waktuUpload != null ? "Tepat waktu" : "-"),
        tugas.waktuUpload == null
            ? _hitungSisaWaktu(tugas.batasPenugasan)
            : "-", // kalau sudah upload, gak perlu tampilkan countdown lagi
        tugas.lampiran != null ? tugas.displayTerlambat : '-',
      ];
    }).toList();

    final bool hasAccess = FeatureAccess.has("tambah_tugas");

    return CustomDataTableWeb(
      headers: headers,
      rows: rows,
      dropdownStatusColumnIndexes: hasAccess ? [7] : null,
      statusColumnIndexes: hasAccess ? null : [7],
      statusOptions: hasAccess ? ['Selesai', 'Proses'] : null,
      onStatusChanged: hasAccess
          ? (rowIndex, newStatus) async {
              final tugas = widget.tugasList[rowIndex];
              final message = await context
                  .read<TugasProvider>()
                  .updateTugasStatus(tugas.id, newStatus);

              NotificationHelper.showTopNotification(
                context,
                message ?? 'Gagal update status',
                isSuccess: message != null,
              );
            }
          : null,
      onView: (actualRowIndex) =>
          _showDetailDialog(context, widget.tugasList[actualRowIndex]),
      onEdit: (actualRowIndex) => _editTugas(context, actualRowIndex),
      onDelete: (actualRowIndex) =>
          _deleteTugas(context, widget.tugasList[actualRowIndex]),
      onTapLampiran: (actualRowIndex) =>
          _showLampiranDialog(context, widget.tugasList[actualRowIndex]),
      onCellTap: (paginatedRowIndex, colIndex, actualRowIndex) {
        final tugas = widget.tugasList[actualRowIndex];
        if (colIndex == 5 && tugas.tugasLat != null && tugas.tugasLng != null) {
          _openMap("${tugas.tugasLat},${tugas.tugasLng}");
        }
        if (colIndex == 6 &&
            tugas.lampiranLat != null &&
            tugas.lampiranLng != null) {
          _openMap("${tugas.lampiranLat},${tugas.lampiranLng}");
        }
      },
    );
  }
}

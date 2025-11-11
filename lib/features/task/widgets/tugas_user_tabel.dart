import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hr/components/dialog/detail_item.dart';
import 'package:hr/components/tabel/main_tabel.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/data/api/api_config.dart';
import 'package:hr/data/models/tugas_model.dart';
import 'package:hr/features/attendance/mobile/absen_form/map/map_page_modal.dart';
import 'package:hr/features/task/tugas_form/form_user_edit.dart';
import 'package:hr/features/task/widgets/lampiran.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

class TugasUserTabel extends StatefulWidget {
  final List<TugasModel> tugasList;
  final VoidCallback? onActionDone;

  const TugasUserTabel({
    super.key,
    required this.tugasList,
    this.onActionDone,
  });

  @override
  State<TugasUserTabel> createState() => _TugasUserTabelState();
}

class _TugasUserTabelState extends State<TugasUserTabel> {
  String getFullUrl(String lampiranPath) {
    final cleaned = lampiranPath.replaceAll('\\', '');
    final fullUrl = cleaned.startsWith('http')
        ? cleaned
        : "${ApiConfig.baseUrl}${cleaned.startsWith('/') ? '' : '/'}$cleaned";

    // debugPrint("🧾 Full URL dipakai Flutter: $fullUrl"); // <--- tambahin ini
    return fullUrl;
  }

// lampiran
  void _showLampiranDialog(BuildContext context, TugasModel tugas) {
    if (tugas.lampiran == null) {
      final message = context.isIndonesian
          ? "Tidak ada lampiran untuk tugas ini"
          : "No attachment for this task";
      NotificationHelper.showTopNotification(
        context,
        message,
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

  // Format HH:mm
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
      final parsed = DateTime.parse(date).toLocal();
      return DateFormat('HH:mm \'-\' dd/MM/yyyy').format(parsed);
    } catch (_) {
      return date;
    }
  }

  // Edit tugas
  Future<void> _editTugas(BuildContext context, int row) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormUserEdit(
          tugas: widget.tugasList[row],
        ),
      ),
    );

    widget.onActionDone?.call();
  }

  /// --- Lokasi tampil di BottomSheet dengan mini Map
  void _openMap(String latlongStr) {
    try {
      final parts = latlongStr.split(',');
      final lat = double.parse(parts[0].trim());
      final lng = double.parse(parts[1].trim());

      showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.bg,
        isScrollControlled: true,
        builder: (_) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 1.0,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  )
                ],
              ),
              child: Stack(
                children: [
                  // Konten bisa discroll
                  Column(
                    children: [
                      // Handle bar
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        height: 5,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      Text(
                        "Lokasi",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.putih,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Map full tinggi fix
                      Expanded(
                        child: MapPageModal(target: LatLng(lat, lng)),
                      ),

                      const SizedBox(height: 200), // dummy biar bisa full drag
                    ],
                  ),

                  // Card info nempel di bawah
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: LocationInfoCard(
                        target: LatLng(lat, lng),
                        mapController: MapController(),
                        onConfirm: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    } catch (_) {
      // debugPrint("Format latlong salah: $latlongStr");
    }
  }

  // Detail dialog
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
            fontSize: 18,
          ),
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          height: MediaQuery.of(context).size.height * 0.5,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: 8,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              switch (index) {
                case 0:
                  return DetailItem(
                      label: context.isIndonesian ? 'Kepada' : 'To',
                      value: tugas.displayUser);
                case 1:
                  return DetailItem(
                      label: context.isIndonesian ? 'Judul' : 'Title',
                      value: tugas.namaTugas);
                case 2:
                  return DetailItem(
                      label:
                          context.isIndonesian ? 'Tanggal Mulai' : 'Start Date',
                      value: parseDate(tugas.tanggalPenugasan));
                case 3:
                  return DetailItem(
                      label: context.isIndonesian ? 'Batas Submit' : 'Deadline',
                      value: parseDate(tugas.batasPenugasan));
                case 4:
                  return DetailItem(
                      label: context.isIndonesian ? 'Lokasi' : 'Location',
                      value: tugas.displayLokasiTugas);
                case 5:
                  return DetailItem(
                      label: context.isIndonesian ? 'Catatan' : 'Note',
                      value: tugas.displayNote);
                case 6:
                  return DetailItem(
                      label: context.isIndonesian ? 'Status' : 'Status',
                      value: tugas.status,
                      color: statusColor);
                default:
                  return const SizedBox();
              }
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              context.isIndonesian ? 'Tutup' : 'Close',
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

  String _hitungSisaWaktu(String? batas) {
    if (batas == null) return "-";
    try {
      final deadline = DateTime.parse(batas);
      final now = DateTime.now();
      final diff = deadline.difference(now);

      if (diff.isNegative) {
        return context.isIndonesian
            ? "Lewat ${diff.inMinutes.abs()} menit"
            : "Overdue by ${diff.inMinutes.abs()} minutes";
      } else {
        final jam = diff.inHours;
        final menit = diff.inMinutes.remainder(60);
        return context.isIndonesian
            ? "$jam jam $menit menit lagi"
            : "$jam hours $menit minutes left";
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
            "Lokasi Upload",
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
            "Upload Location",
            "Status",
            "Note",
            "Attachment",
            "Upload Time",
            "Delay",
            "Remaining Time",
            "Punctuality"
          ];

    // Build rows
    final rows = widget.tugasList.map((tugas) {
      // final hasLampiran = (tugas.lampiran ?? '').toString().trim().isNotEmpty;

      final lampiranLabel =
          (tugas.lampiran != null && tugas.lampiran!.trim().isNotEmpty)
              ? tugas.displayLampiran
              : context.isIndonesian
                  ? "Upload Lampiran"
                  : "Upload Attachment";
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
        lampiranLabel,
        tugas.displayWaktuUpload,
        tugas.menitTerlambat != null
            ? context.isIndonesian
                ? "${tugas.menitTerlambat} menit"
                : "${tugas.menitTerlambat} minute"
            : (tugas.waktuUpload != null
                ? context.isIndonesian
                    ? "Tepat waktu"
                    : "On Time"
                : "-"),
        tugas.waktuUpload == null
            ? _hitungSisaWaktu(tugas.batasPenugasan)
            : "-", // kalau sudah upload, gak perlu tampilkan countdown lagi
        tugas.lampiran != null ? tugas.displayTerlambat : '-',
      ];
    }).toList();

    return CustomDataTableWidget(
      headers: headers,
      rows: rows,
      statusColumnIndexes: const [7], // status di kolom ke-6
      onTapLampiran: (row) {
        final tugas = widget.tugasList[row];
        if (tugas.lampiran != null && tugas.lampiran!.trim().isNotEmpty) {
          _showLampiranDialog(context, tugas);
        } else {
          _editTugas(context, row);
        }
      },
      onCellTap: (row, col) {
        final tugas = widget.tugasList[row];

        if (col == 5 && tugas.tugasLat != null && tugas.tugasLng != null) {
          _openMap("${tugas.tugasLat},${tugas.tugasLng}");
        }
        if (col == 6 &&
            tugas.lampiranLat != null &&
            tugas.lampiranLng != null) {
          _openMap("${tugas.lampiranLat},${tugas.lampiranLng}");
        }
      },
      onView: (row) => _showDetailDialog(context, widget.tugasList[row]),
      onEdit: (row) => _editTugas(context, row),
    );
  }
}

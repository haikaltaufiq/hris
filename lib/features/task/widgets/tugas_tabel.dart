import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hr/components/dialog/detail_item.dart';
import 'package:hr/components/dialog/show_confirmation.dart';
import 'package:hr/components/tabel/main_tabel.dart';
import 'package:hr/core/helpers/feature_guard.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/data/api/api_config.dart';
import 'package:hr/data/models/tugas_model.dart';
import 'package:hr/features/attendance/mobile/absen_form/map/map_page_modal.dart';
import 'package:hr/features/task/task_viewmodel/tugas_provider.dart';
import 'package:hr/features/task/tugas_form/form_user_edit.dart';
import 'package:hr/features/task/tugas_form/tugas_edit_form.dart';
import 'package:hr/features/task/widgets/lampiran.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/helpers/notification_helper.dart';
import '../../../core/theme/app_colors.dart';

class TugasTabel extends StatefulWidget {
  final List<TugasModel> tugasList;
  final VoidCallback? onActionDone;
  const TugasTabel({
    super.key,
    required this.tugasList,
    required this.onActionDone,
  });

  @override
  State<TugasTabel> createState() => _TugasTabelState();
}

String getFullUrl(String lampiranPath) {
  final cleaned = lampiranPath.replaceAll('\\', '');
  final fullUrl = cleaned.startsWith('http')
      ? cleaned
      : "${ApiConfig.baseUrl}${cleaned.startsWith('/') ? '' : '/'}$cleaned";

  // debugPrint("🧾 Full URL dipakai Flutter: $fullUrl"); // <--- tambahin ini
  return fullUrl;
}

class _TugasTabelState extends State<TugasTabel> {
  String parseTime(String? time) {
    if (time == null || time.isEmpty) return '';
    try {
      return DateFormat('HH:mm').format(DateFormat('HH:mm:ss').parse(time));
    } catch (_) {
      return '';
    }
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

  String parseDate(String? date) {
    if (date == null || date.isEmpty) return '';
    try {
      final parsed = DateTime.parse(date).toLocal();
      return DateFormat('dd/MM/yyyy \'-\' HH:mm').format(parsed);
    } catch (_) {
      return date;
    }
  }

  void _handleEditAction(BuildContext context, int row) {
    final tugas = widget.tugasList[row];

    final canUpload = FeatureAccess.has("tambah_lampiran_tugas");
    final canEdit = FeatureAccess.has("edit_tugas");
    final hasLampiran =
        tugas.lampiran != null && tugas.lampiran!.trim().isNotEmpty;

    // ❌ tidak punya akses apa-apa
    if (!canUpload && !canEdit) {
      if (hasLampiran) {
        _showLampiranDialog(context, tugas);
      }
      return;
    }

    // ✅ cuma upload
    if (canUpload && !canEdit) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FormUserEdit(tugas: tugas),
        ),
      );
      return;
    }

    // ✅ cuma edit
    if (!canUpload && canEdit) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TugasEditForm(tugas: tugas),
        ),
      );
      return;
    }

    // 🔥 DUA AKSES → BARU MUNCUL BOTTOM SHEET
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasLampiran)
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: Text("Lihat Lampiran",
                  style: TextStyle(color: AppColors.putih)),
              onTap: () {
                Navigator.pop(context);
                _showLampiranDialog(context, tugas);
              },
            ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: Text("Upload / Ganti Lampiran",
                style: TextStyle(color: AppColors.putih)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FormUserEdit(tugas: tugas),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: Text("Edit Tugas", style: TextStyle(color: AppColors.putih)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TugasEditForm(tugas: tugas),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTugas(BuildContext context, TugasModel tugas) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: context.isIndonesian ? "Konfirmasi Hapus" : "Delete Confirmation",
      content: context.isIndonesian
          ? "Apakah Anda yakin ingin menghapus tugas ini?"
          : "Are you sure you want to delete this task?",
      confirmText: context.isIndonesian ? "Hapus" : "Delete",
      cancelText: context.isIndonesian ? "Batal" : "Cancel",
      confirmColor: AppColors.red,
    );

    if (confirmed) {
      final message = await context.read<TugasProvider>().deleteTugas(tugas.id);
      final messages = context.isIndonesian
          ? 'Gagal menghapus tugas'
          : 'Failed to delete task';
      NotificationHelper.showTopNotification(
        context,
        message ?? messages,
        isSuccess: message != null,
      );
    }
    widget.onActionDone?.call();
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
              label: context.isIndonesian ? 'Kepada' : 'To',
              value: tugas.user?.nama ?? '-',
            ),
            SizedBox(height: 5),
            DetailItem(
              label: context.isIndonesian ? 'Judul' : 'Title',
              value: tugas.namaTugas,
            ),
            DetailItem(
              label: context.isIndonesian ? 'Nama Lokasi' : 'Location Name',
              value: tugas.namaLok,
            ),
            SizedBox(height: 5),
            DetailItem(
              label: context.isIndonesian ? 'Tanggal Mulai' : 'Start Date',
              value: parseDate(tugas.tanggalPenugasan),
            ),
            SizedBox(height: 5),
            DetailItem(
              label: context.isIndonesian ? 'Batas Submit' : 'Deadline',
              value: parseDate(tugas.batasPenugasan),
            ),
            SizedBox(height: 5),
            DetailItem(
              label: context.isIndonesian ? 'Catatan' : 'Note',
              value: tugas.note ?? '-',
            ),
            SizedBox(height: 5),
            DetailItem(
              label: context.isIndonesian ? 'Status' : 'Status',
              value: tugas.status,
              color: statusColor,
            ),
            SizedBox(height: 5),
            DetailItem(
              label: context.isIndonesian ? 'Ketepatan' : 'Punctuality',
              value: tugas.displayTerlambat,
            ),
          ],
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

//
  @override
  Widget build(BuildContext context) {
    final List<String> headers = context.isIndonesian
        ? [
            "Kepada",
            "Judul",
            "Mulai",
            "Batas Submit",
            "Nama Lokasi",
            "Lampiran",
            "Lokasi Upload",
            "Catatan",
            "Status",
          ]
        : [
            "To",
            "Title",
            "Start",
            "Deadline",
            "Location Name",
            "Attachment",
            "Upload Location",
            "Note",
            "Status",
          ];

    final rows = widget.tugasList.map((tugas) {
      final lampiranLabel =
          (tugas.lampiran != null && tugas.lampiran!.trim().isNotEmpty)
              ? tugas.displayLampiran
              : context.isIndonesian
                  ? "Upload Lampiran"
                  : "Upload Attachment";
      final uploadLampiran = FeatureAccess.has("tambah_lampiran_tugas");

      return [
        tugas.displayUser,
        tugas.shortTugas,
        parseDate(tugas.tanggalPenugasan),
        parseDate(tugas.batasPenugasan),
        tugas.namaLok,
        // "${tugas.radius} M",
        // tugas.displayLokasiTugas != null && tugas.displayLokasiTugas != "-"
        //     ? context.isIndonesian
        //         ? "Lihat Lokasi"
        //         : "See Location"
        //     : '-',
        uploadLampiran ? lampiranLabel : tugas.displayLampiran,
        tugas.displayLokasiLampiran != null &&
                tugas.displayLokasiLampiran != "-"
            ? context.isIndonesian
                ? "Lihat Lokasi"
                : "See Location"
            : '-',
        tugas.displayNote,
        tugas.status,
      ];
    }).toList();
    final ubahStatus = FeatureAccess.has("ubah_status_tugas");
    final hapusTugas = FeatureAccess.has("hapus_tugas");
    return CustomDataTableWidget(
      headers: headers,
      rows: rows,
      dropdownStatusColumnIndexes: ubahStatus ? [8] : null,
      statusColumnIndexes: ubahStatus ? null : [8],
      statusOptions: ubahStatus ? ['Selesai', 'Proses'] : null,
      onStatusChanged: (rowIndex, newStatus) async {
        final tugas = widget.tugasList[rowIndex];
        final message = await context
            .read<TugasProvider>()
            .updateTugasStatus(tugas.id, newStatus);
        final messages = context.isIndonesian
            ? 'Gagal update status'
            : 'Failed to update status';
        NotificationHelper.showTopNotification(
          context,
          message ?? messages,
          isSuccess: message != null,
        );
      },
      onView: (row) => _showDetailDialog(context, widget.tugasList[row]),
      onEdit: (row) => _handleEditAction(context, row),
      onDelete: hapusTugas
          ? (row) => _deleteTugas(context, widget.tugasList[row])
          : null,
      onTapLampiran: (row) {
        final tugas = widget.tugasList[row];

        final canUpload = FeatureAccess.has("tambah_lampiran_tugas");
        final hasLampiran =
            tugas.lampiran != null && tugas.lampiran!.trim().isNotEmpty;

        // ada lampiran → siapapun boleh lihat
        if (hasLampiran) {
          _showLampiranDialog(context, tugas);
          return;
        }

        // tidak ada lampiran + punya akses upload
        if (canUpload) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FormUserEdit(tugas: tugas),
            ),
          );
        }

        // tidak ada lampiran + tidak punya akses → DO NOTHING
      },
      onCellTap: (row, col) {
        final tugas = widget.tugasList[row];
        // if (col == 5 && tugas.tugasLat != null && tugas.tugasLng != null) {
        //   _openMap("${tugas.tugasLat},${tugas.tugasLng}");
        // }
        if (col == 6 &&
            tugas.lampiranLat != null &&
            tugas.lampiranLng != null) {
          _openMap("${tugas.lampiranLat},${tugas.lampiranLng}");
        }
      },
    );
  }
}

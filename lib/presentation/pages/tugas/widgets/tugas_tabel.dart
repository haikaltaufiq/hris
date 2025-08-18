import 'package:flutter/material.dart';
import 'package:hr/components/dialog/show_confirmation.dart';
import 'package:hr/data/models/tugas_model.dart';
import 'package:provider/provider.dart';
import 'package:hr/core/theme.dart';
import 'package:hr/presentation/pages/tugas/tugas_form/tugas_edit_form.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/provider/function/tugas_provider.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class TugasTabel extends StatelessWidget {
  const TugasTabel({super.key, required List<TugasModel> tugasList});

  final List<String> headers = const [
    "Judul",
    "Kepada",
    "Jam Mulai",
    "Tanggal Mulai",
    "Batas Submit",
    "Lokasi",
    "Note",
    "Status",
  ];

  String safeSubstring(String? text, int maxLength) {
    if (text == null) return '';
    return text.length <= maxLength
        ? text
        : text.substring(0, maxLength) + '...';
  }

  String parseTime(String? time) {
    if (time == null || time.isEmpty) return '';
    try {
      return DateFormat('HH:mm').format(DateFormat('HH:mm:ss').parse(time));
    } catch (_) {
      return '';
    }
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
      NotificationHelper.showSnackBar(
        context,
        message ?? 'Gagal menghapus lembur',
        isSuccess: message != null,
      );
    }
  }

  String parseDate(String? date) {
    if (date == null || date.isEmpty) return '';
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(date));
    } catch (_) {
      return '';
    }
  }

  void _showDetailDialog(BuildContext context, List<String> values) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.primary,
        title: Text('Detail Tugas',
            style: TextStyle(
                color: AppColors.putih,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(headers.length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        flex: 2,
                        child: Text(headers[index],
                            style: TextStyle(
                                color: AppColors.putih,
                                fontWeight: FontWeight.bold,
                                fontFamily: GoogleFonts.poppins().fontFamily))),
                    Expanded(
                        flex: 3,
                        child: Text(values[index],
                            style: TextStyle(
                                color: AppColors.putih,
                                fontFamily: GoogleFonts.poppins().fontFamily))),
                  ],
                ),
              );
            }),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Tutup',
                  style: TextStyle(
                      color: AppColors.putih,
                      fontFamily: GoogleFonts.poppins().fontFamily))),
        ],
      ),
    );
  }

  Widget buildValueCell(
      BuildContext context, String value, int index, List<String> values) {
    if (index == 0) {
      String displayText = safeSubstring(value, 15);
      return GestureDetector(
          onTap: () => _showDetailDialog(context, values),
          child: Text(displayText,
              style: TextStyle(
                  color: AppColors.putih,
                  fontFamily: GoogleFonts.poppins().fontFamily)));
    }

    if (index == 7) {
      String statusText;
      Color bgColor;
      switch (value) {
        case 'Selesai':
          statusText = "Selesai";
          bgColor = Colors.green;
          break;
        case 'Proses':
          statusText = "Proses";
          bgColor = Colors.orange;
          break;
        default:
          statusText = "Unknown";
          bgColor = Colors.grey;
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: bgColor, width: 1)),
        child: Row(
          children: [
            Container(
                width: 10,
                height: 10,
                decoration:
                    BoxDecoration(color: bgColor, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(statusText,
                style: TextStyle(
                    color: bgColor,
                    fontWeight: FontWeight.bold,
                    fontFamily: GoogleFonts.poppins().fontFamily)),
          ],
        ),
      );
    }

    return Text(value,
        style: TextStyle(
            color: AppColors.putih,
            fontFamily: GoogleFonts.poppins().fontFamily));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TugasProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.tugasList.isEmpty) {
          return const Center(
              child: Text('Belum ada tugas',
                  style: TextStyle(color: Colors.white)));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.tugasList.length,
          itemBuilder: (context, tugasIndex) {
            final tugas = provider.tugasList[tugasIndex];
            final values = [
              tugas.namaTugas,
              tugas.user?.nama ?? '-',
              parseTime(tugas.jamMulai),
              parseDate(tugas.tanggalMulai),
              parseDate(tugas.tanggalSelesai),
              tugas.lokasi,
              tugas.note,
              tugas.status,
            ];

            return Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.02,
                  vertical: MediaQuery.of(context).size.height * 0.01),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: const Color.fromARGB(56, 5, 5, 5),
                        blurRadius: 5,
                        offset: const Offset(0, 1))
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header bar with actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                                value: false,
                                onChanged: (value) {},
                                side: BorderSide(color: AppColors.putih),
                                checkColor: Colors.black,
                                activeColor: AppColors.putih),
                            const SizedBox(width: 8),
                            Text(tugas.user?.nama ?? '-',
                                style: TextStyle(
                                    color: AppColors.putih,
                                    fontFamily:
                                        GoogleFonts.poppins().fontFamily)),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                                icon: FaIcon(FontAwesomeIcons.eye,
                                    color: AppColors.putih, size: 20),
                                onPressed: () =>
                                    _showDetailDialog(context, values)),
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.02),
                            IconButton(
                              icon: FaIcon(FontAwesomeIcons.trash,
                                  color: AppColors.putih, size: 20),
                              onPressed: () => _deleteTugas(context, tugas),
                            ),
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.02),
                            IconButton(
                              icon: FaIcon(FontAwesomeIcons.pen,
                                  color: AppColors.putih, size: 20),
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          TugasEditForm(tugas: tugas))),
                            ),
                          ],
                        )
                      ],
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: FractionallySizedBox(
                        widthFactor: 1.09, // lebih dari 1 = lebar penuh + lebih
                        child: Divider(
                          color: Colors.grey,
                          thickness: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Detail table
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: headers.length,
                      separatorBuilder: (_, __) =>
                          const Divider(color: Colors.grey, thickness: 1),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: Text(headers[index],
                                      style: TextStyle(
                                          color: AppColors.putih,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: GoogleFonts.poppins()
                                              .fontFamily))),
                              Expanded(
                                  flex: 3,
                                  child: buildValueCell(
                                      context, values[index], index, values)),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

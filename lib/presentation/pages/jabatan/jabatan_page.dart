// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/search_bar/search_bar.dart';
import 'package:hr/components/custom/header.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme.dart';
import 'package:hr/data/models/jabatan_model.dart';
import 'package:hr/data/services/jabatan_service.dart';
import 'package:hr/presentation/pages/jabatan/widgets/jabatan_tabel.dart';

class JabatanPage extends StatefulWidget {
  const JabatanPage({super.key});

  @override
  State<JabatanPage> createState() => _JabatanPageState();
}

class _JabatanPageState extends State<JabatanPage> {
  final searchController = TextEditingController();
  final TextEditingController jabatanNameController = TextEditingController();
  late Future<List<JabatanModel>> _jabatanList;

  @override
  void initState() {
    super.initState();
    _jabatanList = JabatanService.fetchJabatan();
  }

  void refreshJabatanList() {
    setState(() {
      _jabatanList = JabatanService.fetchJabatan();
    });
  }

  void createJabatan() async {
    final namaJabatan = jabatanNameController.text.trim();
    if (namaJabatan.isEmpty) {
      NotificationHelper.showTopNotification(
          context, 'Nama jabatan tidak boleh kosong');
      return;
    }

    try {
      final result =
          await JabatanService.createJabatan(namaJabatan: namaJabatan);

      if (result['success']) {
        NotificationHelper.showTopNotification(context, result['message'],
            isSuccess: true);
        refreshJabatanList();
        jabatanNameController.clear();
        Navigator.pop(context);
      } else {
        NotificationHelper.showTopNotification(context, result['message'],
            isSuccess: false);
      }
    } catch (e) {
      NotificationHelper.showTopNotification(context, 'Terjadi kesalahan: $e');
    }
  }

  void updateJabatan(int id) async {
    final namaJabatan = jabatanNameController.text.trim();
    if (namaJabatan.isEmpty) {
      NotificationHelper.showTopNotification(
          context, 'Nama jabatan tidak boleh kosong');
      return;
    }

    try {
      final result =
          await JabatanService.updateJabatan(id: id, namaJabatan: namaJabatan);

      if (result['success']) {
        NotificationHelper.showTopNotification(context, result['message'],
            isSuccess: true);
        refreshJabatanList();
        jabatanNameController.clear();
        Navigator.pop(context);
      } else {
        NotificationHelper.showTopNotification(context, result['message'],
            isSuccess: false);
      }
    } catch (e) {
      NotificationHelper.showTopNotification(context, 'Terjadi kesalahan: $e');
    }
  }

  void deleteJabatan(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Jabatan"),
        content: const Text("Apakah Anda yakin ingin menghapus jabatan ini?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Batal")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Hapus", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      final result = await JabatanService.deleteJabatan(id);
      if (result['success']) {
        NotificationHelper.showTopNotification(context, result['message'],
            isSuccess: true);
        setState(() {
          _jabatanList = JabatanService.fetchJabatan();
        });
      } else {
        NotificationHelper.showTopNotification(context, result['message'],
            isSuccess: false);
      }
    }
  }

  Widget buildJabatanDialog({
    required String title,
    required VoidCallback onSubmit,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: screenHeight * 0.8, maxWidth: screenWidth * 0.9),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  color: AppColors.putih,
                  fontWeight: FontWeight.w600,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: jabatanNameController,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.putih),
                cursorColor: AppColors.putih,
                decoration: InputDecoration(
                  hintText: 'Nama Jabatan',
                  hintStyle: TextStyle(
                    color: AppColors.putih,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: AppColors.secondary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.grey,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text('Cancel',
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: GoogleFonts.poppins().fontFamily)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: onSubmit,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text('Submit',
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: GoogleFonts.poppins().fontFamily)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Header(title: 'Manajemen Jabatan'),
            SearchingBar(
              controller: searchController,
              onChanged: (value) => print("Search Halaman Jabatan: $value"),
              onFilter1Tap: () => print("Filter1 Jabatan"),
            ),
            FutureBuilder<List<JabatanModel>>(
              future: _jabatanList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Tidak ada data jabatan'));
                } else {
                  return JabatanTabel(
                    jabatanList: snapshot.data!,
                    onEdit: (jabatan) {
                      jabatanNameController.text = jabatan.namaJabatan;
                      showDialog(
                        context: context,
                        builder: (_) => buildJabatanDialog(
                          title: 'Edit Jabatan',
                          onSubmit: () => updateJabatan(jabatan.id),
                        ),
                      );
                    },
                    onDelete: (id) => deleteJabatan(id),
                  );
                }
              },
            ),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () {
              jabatanNameController.clear();
              showDialog(
                context: context,
                builder: (_) => buildJabatanDialog(
                  title: 'Tambah Jabatan',
                  onSubmit: createJabatan,
                ),
              );
            },
            backgroundColor: AppColors.secondary,
            shape: const CircleBorder(),
            child: FaIcon(FontAwesomeIcons.plus, color: AppColors.putih),
          ),
        )
      ],
    );
  }
}

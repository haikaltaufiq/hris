import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/loading.dart';
import 'package:hr/components/dialog/show_confirmation.dart';
import 'package:hr/components/search_bar/search_bar.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/features/jabatan/jabatan_viewmodels.dart';
import 'package:hr/features/jabatan/web/web_tabel_jabat.dart';
import 'package:provider/provider.dart';

class WebPageJabatan extends StatefulWidget {
  const WebPageJabatan({super.key});

  @override
  State<WebPageJabatan> createState() => _WebPageJabatanState();
}

class _WebPageJabatanState extends State<WebPageJabatan> {
  final searchController = TextEditingController();

  final jabatanNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JabatanViewModel>().fetchJabatan(context);
    });
  }

  Widget buildJabatanDialog({
    required String title,
    required VoidCallback onSubmit,
  }) {
    return Dialog(
      backgroundColor: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 600, // atur width dialog
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  color: AppColors.putih,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: jabatanNameController,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.putih),
                decoration: InputDecoration(
                  hintText: 'Nama Jabatan',
                  hintStyle: TextStyle(
                    color: AppColors.putih,
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
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: GoogleFonts.poppins().fontFamily)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                      onPressed: onSubmit,
                      child: Text('Submit',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: GoogleFonts.poppins().fontFamily)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Consumer<JabatanViewModel>(
        builder: (context, vm, child) {
          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  SearchingBar(
                    controller: searchController,
                    onChanged: (value) => vm.search(value),
                    onFilter1Tap: () {}, // kosong sesuai request
                  ),
                  if (vm.isLoading)
                    const Center(child: LoadingWidget())
                  else if (vm.jabatanList.isEmpty)
                    const Center(child: Text('Tidak ada data jabatan'))
                  else
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: WebTabelJabat(
                        jabatanList: vm.jabatanList,
                        onEdit: (jabatan) {
                          jabatanNameController.text = jabatan.namaJabatan;
                          showDialog(
                            context: context,
                            builder: (_) => buildJabatanDialog(
                              title: 'Edit Jabatan',
                              onSubmit: () {
                                vm.updateJabatan(context, jabatan.id,
                                    jabatanNameController.text);
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                        onDelete: (id) async {
                          final confirmed = await showConfirmationDialog(
                            context,
                            title: "Konfirmasi Hapus",
                            content:
                                "Apakah Anda yakin ingin menghapus departemen ini?",
                            confirmText: "Hapus",
                            cancelText: "Batal",
                            confirmColor: AppColors.red,
                          );
                          if (confirmed) {
                            await vm.deleteJabatan(context, id);
                          }
                        },
                      ),
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
                        onSubmit: () {
                          vm.createJabatan(context, jabatanNameController.text);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                  backgroundColor: AppColors.secondary,
                  shape: const CircleBorder(),
                  child: FaIcon(FontAwesomeIcons.plus, color: AppColors.putih),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

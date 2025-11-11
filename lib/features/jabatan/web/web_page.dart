import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/loading.dart';
import 'package:hr/components/custom/sorting.dart';
import 'package:hr/components/dialog/show_confirmation.dart';
import 'package:hr/components/search_bar/search_bar.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
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
      final vm = context.read<JabatanViewModel>();
      vm.loadCacheFirst();
      if (!vm.hasCache) {
        vm.fetchJabatan();
      }
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
                  hintText:
                      context.isIndonesian ? 'Nama Jabatan' : 'Add Position',
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
    return Consumer<JabatanViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          backgroundColor: AppColors.bg,
          body: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  SearchingBar(
                    controller: searchController,
                    onChanged: (value) => vm.search(value),
                    onFilter1Tap: () async {
                      final provider = context.read<JabatanViewModel>();

                      final selected = await showSortDialog(
                        context: context,
                        title: context.isIndonesian
                            ? 'Urutkan Berdasarkan'
                            : 'Sort By',
                        currentValue: provider.currentSortField,
                        options: [
                          {
                            'value': 'terbaru',
                            'label': context.isIndonesian ? 'Terbaru' : 'Newest'
                          },
                          {
                            'value': 'terlama',
                            'label': context.isIndonesian ? 'Terlama' : 'Oldest'
                          },
                        ],
                      );

                      if (selected != null) {
                        provider.sortJabatan(selected);
                      }

                      if (selected != null) {
                        provider.sortJabatan(selected);
                      }
                    },
                  ),
                  if (vm.isLoading)
                    const Center(child: LoadingWidget())
                  else if (vm.jabatanList.isEmpty)
                    Center(
                        child: Text(context.isIndonesian
                            ? 'Tidak ada data jabatan'
                            : 'No Position available'))
                  else
                    WebTabelJabat(
                      jabatanList: vm.jabatanList,
                      onEdit: (jabatan) {
                        jabatanNameController.text = jabatan.namaJabatan;
                        showDialog(
                          context: context,
                          builder: (_) => buildJabatanDialog(
                            title: context.isIndonesian
                                ? 'Edit Jabatan'
                                : 'Edit Position',
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
                          title: context.isIndonesian
                              ? "Konfirmasi Hapus"
                              : "Delete Confirmation",
                          content: context.isIndonesian
                              ? "Apakah Anda yakin ingin menghapus jabatan ini?"
                              : "Are you sure you want to delete this position?",
                          confirmText:
                              context.isIndonesian ? "Hapus" : "Delete",
                          cancelText: context.isIndonesian ? "Batal" : "Cancel",
                          confirmColor: AppColors.red,
                        );
                        if (confirmed) {
                          vm.deleteJabatan(context, id);
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
                        title: context.isIndonesian
                            ? 'Tambah Jabatan'
                            : 'Add position',
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
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/header.dart';
import 'package:hr/components/custom/loading.dart';
import 'package:hr/components/search_bar/search_bar.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/features/jabatan/jabatan_viewmodels.dart';
import 'package:hr/features/jabatan/widgets/jabatan_tabel.dart';
import 'package:provider/provider.dart';

class JabatanPageMobile extends StatefulWidget {
  const JabatanPageMobile({super.key});

  @override
  State<JabatanPageMobile> createState() => _JabatanPageMobileState();
}

class _JabatanPageMobileState extends State<JabatanPageMobile> {
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 20,
                    color: AppColors.putih,
                    fontWeight: FontWeight.w600,
                    fontFamily: GoogleFonts.poppins().fontFamily)),
            const SizedBox(height: 24),
            TextField(
              controller: jabatanNameController,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.putih),
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
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.grey,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30))),
                    onPressed: () => Navigator.pop(context),
                    child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('Cancel',
                            style: TextStyle(color: Colors.white))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30))),
                    onPressed: onSubmit,
                    child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('Submit',
                            style: TextStyle(color: Colors.white))),
                  ),
                ),
              ],
            )
          ],
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
          body: Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
            ),
            child: Stack(
              children: [
                ListView(
                  children: [
                    Header(title: 'Manajemen Jabatan'),
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
                      JabatanTabel(
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
                        onDelete: (id) {
                          vm.deleteJabatan(context, id);
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
                          onSubmit: () {
                            vm.createJabatan(
                                context, jabatanNameController.text);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                    backgroundColor: AppColors.secondary,
                    shape: const CircleBorder(),
                    child:
                        FaIcon(FontAwesomeIcons.plus, color: AppColors.putih),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hr/components/custom/header.dart';
import 'package:hr/components/custom/loading.dart';
import 'package:hr/components/custom/sorting.dart';
import 'package:hr/components/dialog/show_confirmation.dart';
import 'package:hr/components/search_bar/search_bar.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/features/department/view_model/department_viewmodels.dart';
import 'package:hr/features/department/widgets/department_tabel.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class DepartemenPageMobile extends StatefulWidget {
  const DepartemenPageMobile({super.key});

  @override
  State<DepartemenPageMobile> createState() => _DepartemenPageMobileState();
}

class _DepartemenPageMobileState extends State<DepartemenPageMobile> {
  final searchController = TextEditingController();
  final departmentNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Ambil provider sekali saat halaman pertama kali
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<DepartmentViewModel>();

      // Load cache first (synchronous with notifyListeners)
      vm.loadCacheFirst();

      // Then fetch fresh data if needed
      if (!vm.hasCache) {
        await vm.fetchDepartemen(); // Proper await
      } else {
        // Ada cache, tapi tetap fetch di background tanpa loading indicator
        vm.fetchDepartemen(forceRefresh: false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DepartmentViewModel>(
      builder: (context, vm, _) {
        final departemen =
            searchController.text.isEmpty ? vm.departemenList : vm.filteredList;

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
                    Header(
                        title: context.isIndonesian
                            ? 'Manajemen Departemen'
                            : 'Department Management'),
                    SearchingBar(
                      controller: searchController,
                      onChanged: (value) => vm.searchDepartemen(value),
                      onFilter1Tap: () async {
                        final provider = context.read<DepartmentViewModel>();

                        final selected = await showSortDialog(
                          context: context,
                          title: 'Urutkan Departemen Berdasarkan',
                          currentValue: provider.currentSortField,
                          options: [
                            {'value': 'terbaru', 'label': 'Terbaru'},
                            {'value': 'terlama', 'label': 'Terlama'},
                          ],
                        );

                        if (selected != null) {
                          provider.sortDepartemen(selected);
                        }

                        if (selected != null) {
                          provider.sortDepartemen(selected);
                        }
                      },
                    ),
                    if (vm.isLoading)
                      const Center(child: LoadingWidget())
                    else if (departemen.isEmpty)
                      Center(
                          child: Text(context.isIndonesian
                              ? 'Tidak ada data departemen'
                              : 'No data available'))
                    else
                      DepartmentTabel(
                        departemenList: departemen,
                        onEdit: (departemen) {
                          departmentNameController.text =
                              departemen.namaDepartemen;
                          showDialog(
                            context: context,
                            builder: (_) => _buildDepartmentDialog(
                              context,
                              title: 'Edit Department',
                              controller: departmentNameController,
                              onSubmit: () async {
                                final result = await vm.updateDepartemen(
                                  departemen.id,
                                  departmentNameController.text.trim(),
                                );
                                Navigator.pop(context);

                                NotificationHelper.showTopNotification(
                                    context, result['message'],
                                    isSuccess: result['success']);
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
                            final result = await vm.deleteDepartemen(id);
                            NotificationHelper.showTopNotification(
                                context, result['message'],
                                isSuccess: result['success']);
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
                      departmentNameController.clear();
                      showDialog(
                        context: context,
                        builder: (_) => _buildDepartmentDialog(
                          context,
                          title: context.isIndonesian
                              ? 'Tambah Department'
                              : 'Add Department',
                          controller: departmentNameController,
                          onSubmit: () async {
                            final result = await vm.createDepartemen(
                                departmentNameController.text.trim());
                            Navigator.pop(context);

                            NotificationHelper.showTopNotification(
                                context, result['message'],
                                isSuccess: result['success']);
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

  Widget _buildDepartmentDialog(
    BuildContext context, {
    required String title,
    required TextEditingController controller,
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
              controller: controller,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.putih),
              cursorColor: AppColors.putih,
              decoration: InputDecoration(
                hintText: context.isIndonesian
                    ? 'Nama Department'
                    : 'Department Name',
                hintStyle: TextStyle(
                  color: AppColors.putih,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w100,
                ),
                filled: true,
                fillColor: AppColors.secondary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
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
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: onSubmit,
                    child: Text('Submit',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: GoogleFonts.poppins().fontFamily)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

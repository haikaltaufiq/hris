import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
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

class WebPageDepartment extends StatefulWidget {
  const WebPageDepartment({super.key});

  @override
  State<WebPageDepartment> createState() => _WebPageDepartmentState();
}

class _WebPageDepartmentState extends State<WebPageDepartment> {
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
          body: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  SearchingBar(
                    controller: searchController,
                    onChanged: (value) {
                      vm.searchDepartemen(value);
                      setState(() {}); // rebuild untuk update list search
                    },
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
                            : 'No Data Available'))
                  else
                    DepartmentTabel(
                      departemenList: departemen,
                      onEdit: (d) {
                        departmentNameController.text = d.namaDepartemen;
                        showDialog(
                          context: context,
                          builder: (_) => _buildDepartmentDialog(
                            context,
                            title: context.isIndonesian
                                ? 'Edit Department'
                                : 'Edit Department',
                            controller: departmentNameController,
                            onSubmit: () async {
                              final result = await vm.updateDepartemen(
                                d.id,
                                departmentNameController.text.trim(),
                              );
                              NotificationHelper.showTopNotification(
                                context,
                                result['message'],
                                isSuccess: result['success'],
                              );
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
                              : 'Delete Confirmation',
                          content:
                              "Apakah Anda yakin ingin menghapus departemen ini?",
                          confirmText: "Hapus",
                          cancelText: "Batal",
                          confirmColor: AppColors.red,
                        );
                        if (confirmed) {
                          final result = await vm.deleteDepartemen(id);
                          NotificationHelper.showTopNotification(
                            context,
                            result['message'],
                            isSuccess: result['success'],
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
                          NotificationHelper.showTopNotification(
                            context,
                            result['message'],
                            isSuccess: result['success'],
                          );
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

Widget _buildDepartmentDialog(
  BuildContext context, {
  required String title,
  required TextEditingController controller,
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
                  color: AppColors.putih.withOpacity(0.5),
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
                      padding: const EdgeInsets.symmetric(vertical: 24),
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
                      padding: const EdgeInsets.symmetric(vertical: 24),
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
    ),
  );
}

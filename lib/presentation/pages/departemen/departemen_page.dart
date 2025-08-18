// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/search_bar/search_bar.dart';
import 'package:hr/components/custom/header.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme.dart';
import 'package:hr/data/models/departemen_model.dart';
import 'package:hr/data/services/departemen_service.dart';
import 'package:hr/presentation/pages/departemen/widgets/department_tabel.dart';

class DepartemenPage extends StatefulWidget {
  const DepartemenPage({super.key});

  @override
  State<DepartemenPage> createState() => _DepartemenPageState();
}

class _DepartemenPageState extends State<DepartemenPage> {
  final searchController = TextEditingController();
  final TextEditingController departmentNameController =
      TextEditingController();
  late Future<List<DepartemenModel>> _departemenList;

  @override
  void initState() {
    super.initState();
    _departemenList = DepartemenService.fetchDepartemen();
  }

  Widget buildDepartmentDialog({
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
          maxHeight: screenHeight * 0.8,
          maxWidth: screenWidth * 0.9,
        ),
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
                controller: departmentNameController,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.putih),
                cursorColor: AppColors.putih,
                decoration: InputDecoration(
                  hintText: 'Nama Department',
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
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('Cancel',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: onSubmit,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('Submit',
                            style: TextStyle(color: Colors.white)),
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

  void createDepartment() async {
    final namaDepartemen = departmentNameController.text.trim();

    if (namaDepartemen.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama departemen tidak boleh kosong')),
      );
      return;
    }

    try {
      final result = await DepartemenService.createDepartemen(
        namaDepartemen: namaDepartemen,
      );

      if (result['success']) {
        NotificationHelper.showSnackBar(context, result['message'],
            isSuccess: true);
        setState(() {
          _departemenList = DepartemenService.fetchDepartemen();
        });
        departmentNameController.clear();
        Navigator.pop(context);
      } else {
        NotificationHelper.showSnackBar(context, result['message'],
            isSuccess: false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  void updateDepartment(int id) async {
    final namaDepartemen = departmentNameController.text.trim();

    if (namaDepartemen.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama departemen tidak boleh kosong')),
      );
      return;
    }

    try {
      final result = await DepartemenService.updateDepartemen(
        id: id,
        namaDepartemen: namaDepartemen,
      );

      if (result['success']) {
        NotificationHelper.showSnackBar(context, result['message'],
            isSuccess: true);
        setState(() {
          _departemenList = DepartemenService.fetchDepartemen();
        });
        departmentNameController.clear();
        Navigator.pop(context);
      } else {
        NotificationHelper.showSnackBar(context, result['message'],
            isSuccess: false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  void deleteDepartment(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Yakin mau hapus departemen ini?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus')),
        ],
      ),
    );

    if (confirm == true) {
      final result = await DepartemenService.deleteDepartemen(id);
      if (result['success']) {
        NotificationHelper.showSnackBar(context, result['message'],
            isSuccess: true);
        setState(() {
          _departemenList = DepartemenService.fetchDepartemen();
        });
      } else {
        NotificationHelper.showSnackBar(context, result['message'],
            isSuccess: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Header(title: 'Manajemen Departemen'),
            SearchingBar(
              controller: searchController,
              onChanged: (value) {
                print("Search Halaman A: $value");
              },
              onFilter1Tap: () => print("Filter1 Halaman A"),
            ),
            FutureBuilder<List<DepartemenModel>>(
              future: _departemenList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Tidak ada data departemen'));
                } else {
                  return DepartmentTabel(
                    departemenList: snapshot.data!,
                    onEdit: (departemen) {
                      departmentNameController.text = departemen.namaDepartemen;
                      showDialog(
                        context: context,
                        builder: (_) => buildDepartmentDialog(
                          title: 'Edit Department',
                          onSubmit: () => updateDepartment(departemen.id),
                        ),
                      );
                    },
                    onDelete: (id) => deleteDepartment(id),
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
                builder: (_) => buildDepartmentDialog(
                  title: 'Tambah Department',
                  onSubmit: createDepartment,
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
  }
}

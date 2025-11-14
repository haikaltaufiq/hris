// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/custom_dropdown.dart';
import 'package:hr/components/custom/custom_input.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/data/models/peran_model.dart';
import 'package:hr/data/models/user_model.dart';
import 'package:hr/data/services/departemen_service.dart';
import 'package:hr/data/services/jabatan_service.dart';
import 'package:hr/data/services/peran_service.dart';
import 'package:hr/features/auth/login_viewmodels.dart/login_provider.dart';
import 'package:provider/provider.dart';

class KaryawanInputEdit extends StatefulWidget {
  final UserModel user;
  const KaryawanInputEdit({super.key, required this.user});

  @override
  State<KaryawanInputEdit> createState() => _KaryawanInputEditState();
}

class _KaryawanInputEditState extends State<KaryawanInputEdit> {
  // Controllers
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _gajiController = TextEditingController();
  final TextEditingController _npwpController = TextEditingController();
  final TextEditingController _bpjsKesController = TextEditingController();
  final TextEditingController _bpjsKetController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  // Dropdown values
  int? _jabatanId;
  int? _peranId;
  int? _departemenId;
  String? _jenisKelamin;
  String? _statusPernikahan;

  // Data lists
  List<Map<String, Object>> _jabatanList = [];
  List<PeranModel> _peranList = [];
  List<Map<String, Object>> _departemenList = [];

  // Loading states
  bool _isLoadingJabatan = true;
  bool _isLoadingPeran = true;
  bool _isLoadingDepartemen = true;
  bool _isSubmitting = false;
  bool obscure = true;
  // Static dropdown data
  final List<String> _jenisKelaminList = ["Laki-laki", "Perempuan"];
  final List<String> _statusList = ["Menikah", "Belum Menikah"];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    // Load dropdown data
    _loadJabatan();
    _loadPeran();
    _loadDepartemen();

    // Prefill controllers
    _namaController.text = widget.user.nama;
    _gajiController.text = widget.user.gajiPokok?.toString() ?? '';
    _npwpController.text = widget.user.npwp ?? '';
    _bpjsKesController.text = widget.user.bpjsKesehatan ?? '';
    _bpjsKetController.text = widget.user.bpjsKetenagakerjaan ?? '';
    _jenisKelamin = widget.user.jenisKelamin;
    _statusPernikahan = widget.user.statusPernikahan;

    // Prefill IDs
    _jabatanId = widget.user.jabatan?.id;
    _peranId = widget.user.peran?.id;
    _departemenId = widget.user.departemen?.id;
  }

  Future<void> _loadJabatan() async {
    try {
      final data = await JabatanService.fetchJabatan();
      if (mounted) {
        //  Safety check
        setState(() {
          _jabatanList = data
              .map((j) => {"id": j.id, "nama_jabatan": j.namaJabatan})
              .toList();
          _jabatanId ??= widget.user.jabatan?.id;
          _isLoadingJabatan = false;
        });
      }
    } catch (e) {
      if (mounted) {
        //  Safety check
        setState(() => _isLoadingJabatan = false);
        final message = context.isIndonesian
            ? "Gagal memuat jabatan: $e"
            : "Failed to load positions: $e";
        NotificationHelper.showTopNotification(context, message,
            isSuccess: false);
      }
    }
  }

  Future<void> _loadPeran() async {
    try {
      final data = await PeranService.fetchPeran();
      if (mounted) {
        // ✅ Safety check
        setState(() {
          _peranList = data;
          _isLoadingPeran = false;
        });
      }
    } catch (e) {
      if (mounted) {
        // ✅ Safety check
        setState(() => _isLoadingPeran = false);
        final message = context.isIndonesian
            ? "Gagal memuat peran: $e"
            : "Failed to load roles: $e";
        NotificationHelper.showTopNotification(context, message,
            isSuccess: false);
      }
    }
  }

  Future<void> _loadDepartemen() async {
    try {
      final data = await DepartemenService.fetchDepartemen();
      if (mounted) {
        //  Safety check
        setState(() {
          _departemenList = data
              .map((d) => {"id": d.id, "nama_departemen": d.namaDepartemen})
              .toList();
          _departemenId ??= widget.user.departemen?.id;
          _isLoadingDepartemen = false;
        });
      }
    } catch (e) {
      if (mounted) {
        //  Safety check
        setState(() => _isLoadingDepartemen = false);
        final message = context.isIndonesian
            ? "Gagal memuat departemen: $e"
            : "Failed to load departments: $e";
        NotificationHelper.showTopNotification(context, message,
            isSuccess: false);
      }
    }
  }

  // ✅ Safe dropdown hint helper tuntuk yang type objek
  String _getSafeDropdownHint<T>(bool isLoading, int? selectedId, List<T> items,
      String Function(T) getLabel) {
    if (isLoading) return 'Memuat...';
    if (selectedId == null) return 'Pilih...';

    try {
      final selectedItem = items.firstWhere(
        (item) => (item as dynamic).id == selectedId,
      );
      return getLabel(selectedItem);
    } catch (e) {
      return 'Pilih...';
    }
  }

  Future<void> _submitData() async {
    if (_isSubmitting) return;

    // Validasi form
    if (_namaController.text.isEmpty ||
        _jabatanId == null ||
        _peranId == null ||
        _departemenId == null ||
        _gajiController.text.isEmpty ||
        _jenisKelamin == null ||
        _statusPernikahan == null) {
      final message = context.isIndonesian
          ? "Harap isi semua field"
          : "Please fill in all fields";
      NotificationHelper.showTopNotification(
        context,
        message,
        isSuccess: false,
      );
      return;
    }

    // Validasi gaji harus angka
    final gaji = int.tryParse(_gajiController.text.trim());
    if (gaji == null) {
      final message = context.isIndonesian
          ? "Gaji harus berupa angka"
          : "Salary must be a number";
      NotificationHelper.showTopNotification(
        context,
        message,
        isSuccess: false,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      final body = {
        "nama": _namaController.text.trim(),
        "peran_id": _peranId,
        "jabatan_id": _jabatanId,
        "departemen_id": _departemenId,
        "gaji_per_hari": gaji,
        "npwp": _npwpController.text.trim(),
        "bpjs_kesehatan": _bpjsKesController.text.trim(),
        "bpjs_ketenagakerjaan": _bpjsKetController.text.trim(),
        "jenis_kelamin": _jenisKelamin,
        "status_pernikahan": _statusPernikahan,
      };

      // Tambahkan password jika ada perubahan
      if (_newPasswordController.text.isNotEmpty) {
        body.addAll({
          "password": _newPasswordController.text.trim(),
          "password_confirmation": _newPasswordController.text.trim(),
        });
      }

      final response = await userProvider.updateUser(widget.user.id, body);

      if (response['success'] == true) {
        if (mounted) {
          NotificationHelper.showTopNotification(
            context,
            context.isIndonesian
                ? "Data karyawan berhasil diperbarui"
                : "Employee data updated successfully",
            isSuccess: true,
          );
          Navigator.pop(context, true);
        }
      } else if (response.containsKey('errors')) {
        // Gabung semua pesan error jadi satu string tanpa field
        final errors = response['errors'] as Map<String, dynamic>;
        final errorMessages =
            errors.values.expand((messages) => messages as List).join(', ');

        if (mounted) {
          NotificationHelper.showTopNotification(
            context,
            errorMessages,
            isSuccess: false,
          );
        }
      } else {
        if (mounted) {
          NotificationHelper.showTopNotification(
            context,
            response['message'] ??
                (context.isIndonesian
                    ? "Terjadi kesalahan"
                    : "An error occurred"),
            isSuccess: false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        NotificationHelper.showTopNotification(
          context,
          context.isIndonesian
              ? "Gagal memperbarui data: $e"
              : "Failed to update data: $e",
          isSuccess: false,
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _gajiController.dispose();
    _npwpController.dispose();
    _bpjsKesController.dispose();
    _bpjsKetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inputStyle = InputDecoration(
      hintStyle: TextStyle(color: AppColors.putih.withOpacity(0.7)),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.grey),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.putih),
      ),
    );

    final labelStyle = GoogleFonts.poppins(
      fontWeight: FontWeight.bold,
      color: AppColors.putih,
      fontSize: 16,
    );

    final textStyle = GoogleFonts.poppins(
      color: AppColors.putih,
      fontSize: 14,
    );

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05,
          vertical: MediaQuery.of(context).size.height * 0.01,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomInputField(
              controller: _namaController,
              label: context.isIndonesian ? "Nama *" : "Name *",
              hint: context.isIndonesian
                  ? "Masukkan nama karyawan"
                  : "Input employees name",
              labelStyle: labelStyle,
              textStyle: textStyle,
              inputStyle: inputStyle,
            ),

            CustomDropDownField(
              label: context.isIndonesian ? 'Jabatan *' : 'Position *',
              hint: _isLoadingJabatan
                  ? 'Memuat...'
                  : _jabatanId != null
                      ? _jabatanList
                          .firstWhere((e) => e['id'] == _jabatanId,
                              orElse: () =>
                                  {"nama_jabatan": "Pilih..."})['nama_jabatan']
                          .toString()
                      : 'Pilih...',
              items: _isLoadingJabatan
                  ? []
                  : _jabatanList
                      .where((e) => e["nama_jabatan"] != null)
                      .map((e) => e["nama_jabatan"] as String)
                      .toList(),
              onChanged: _isLoadingJabatan
                  ? null
                  : (val) {
                      if (val != null) {
                        final selected = _jabatanList.firstWhere(
                          (e) => e["nama_jabatan"] == val,
                          orElse: () => <String, Object>{},
                        );
                        if (selected.isNotEmpty) {
                          setState(() {
                            _jabatanId = selected["id"] as int?;
                          });
                        }
                      }
                    },
              labelStyle: labelStyle,
              textStyle: textStyle,
              dropdownColor: AppColors.secondary,
              dropdownTextColor: AppColors.putih,
              dropdownIconColor: AppColors.putih,
              inputStyle: inputStyle,
            ),

            CustomDropDownField(
              label: context.isIndonesian ? 'Peran *' : 'Role *',
              hint: _getSafeDropdownHint<PeranModel>(
                _isLoadingPeran,
                _peranId,
                _peranList,
                (e) => e.namaPeran, // sekarang pakai properti model
              ),
              items: _isLoadingPeran
                  ? []
                  : _peranList
                      .where((e) => e.namaPeran.isNotEmpty)
                      .map((e) => e.namaPeran)
                      .toList(),
              onChanged: _isLoadingPeran
                  ? null
                  : (val) {
                      if (val != null) {
                        final selected = _peranList.firstWhere(
                          (e) => e.namaPeran == val,
                          orElse: () =>
                              PeranModel(id: 0, namaPeran: '', fitur: []),
                        );
                        if (selected.id != 0) {
                          setState(() {
                            _peranId = selected.id;
                          });
                        }
                      }
                    },
              labelStyle: labelStyle,
              textStyle: textStyle,
              dropdownColor: AppColors.secondary,
              dropdownTextColor: AppColors.putih,
              dropdownIconColor: AppColors.putih,
              inputStyle: inputStyle,
            ),

            CustomDropDownField(
              label: context.isIndonesian ? 'Departemen *' : 'Department *',
              hint: _isLoadingDepartemen
                  ? 'Memuat...'
                  : _departemenId != null
                      ? _departemenList
                          .firstWhere((e) => e['id'] == _departemenId,
                              orElse: () => {
                                    "nama_departemen": "Pilih..."
                                  })['nama_departemen']
                          .toString()
                      : 'Pilih...',
              items: _isLoadingDepartemen
                  ? []
                  : _departemenList
                      .where((e) => e["nama_departemen"] != null)
                      .map((e) => e["nama_departemen"] as String)
                      .toList(),
              onChanged: _isLoadingDepartemen
                  ? null
                  : (val) {
                      if (val != null) {
                        final selected = _departemenList.firstWhere(
                          (e) => e["nama_departemen"] == val,
                          orElse: () => <String, Object>{},
                        );
                        if (selected.isNotEmpty) {
                          setState(() {
                            _departemenId = selected["id"] as int?;
                          });
                        }
                      }
                    },
              labelStyle: labelStyle,
              textStyle: textStyle,
              dropdownColor: AppColors.secondary,
              dropdownTextColor: AppColors.putih,
              dropdownIconColor: AppColors.putih,
              inputStyle: inputStyle,
            ),

            CustomInputField(
              controller: _gajiController,
              label:
                  context.isIndonesian ? "Gaji Per Hari *" : "Daily Salary *",
              hint: context.isIndonesian
                  ? "Masukkan gaji per hari"
                  : "Input daily Salary",
              labelStyle: labelStyle,
              textStyle: textStyle,
              inputStyle: inputStyle,
            ),

            CustomInputField(
              controller: _npwpController,
              label: "NPWP",
              hint: context.isIndonesian ? "Masukkan NPWP " : "Input NPWP ",
              labelStyle: labelStyle,
              textStyle: textStyle,
              inputStyle: inputStyle,
            ),

            CustomInputField(
              controller: _bpjsKetController,
              label: "No. BPJS Ketenagakerjaan",
              hint: context.isIndonesian
                  ? "Masukkan nomor BPJS Ketenagakerjaan"
                  : "Input BPJS Ketenagakerjaan",
              labelStyle: labelStyle,
              textStyle: textStyle,
              inputStyle: inputStyle,
            ),

            CustomInputField(
              controller: _bpjsKesController,
              label: "No. BPJS Kesehatan",
              hint: context.isIndonesian
                  ? "Masukkan nomor BPJS Kesehatan"
                  : "Optional",
              labelStyle: labelStyle,
              textStyle: textStyle,
              inputStyle: inputStyle,
            ),
            CustomPasswordField(
              controller: _newPasswordController,
              label: "Change Password",
              hint: context.isIndonesian
                  ? "Masukkan password baru"
                  : "Input new password",
              labelStyle: labelStyle,
              textStyle: textStyle,
              inputStyle: inputStyle,
            ),

            CustomDropDownField(
              label: context.isIndonesian ? 'Jenis Kelamin *' : 'Gender *',
              hint: _jenisKelamin ?? 'Pilih jenis kelamin',
              items: _jenisKelaminList,
              onChanged: (val) => setState(() => _jenisKelamin = val),
              labelStyle: labelStyle,
              textStyle: textStyle,
              dropdownColor: AppColors.secondary,
              dropdownTextColor: AppColors.putih,
              dropdownIconColor: AppColors.putih,
              inputStyle: inputStyle,
            ),

            CustomDropDownField(
              label: context.isIndonesian
                  ? 'Status Pernikahan *'
                  : 'Marriage Status',
              hint: _statusPernikahan ?? 'Pilih status pernikahan',
              items: _statusList,
              onChanged: (val) => setState(() => _statusPernikahan = val),
              labelStyle: labelStyle,
              textStyle: textStyle,
              dropdownColor: AppColors.secondary,
              dropdownTextColor: AppColors.putih,
              dropdownIconColor: AppColors.putih,
              inputStyle: inputStyle,
            ),

            const SizedBox(height: 20),

            // ✅ Enhanced Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitData,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isSubmitting ? Colors.grey : const Color(0xFF1F1F1F),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ],
                      )
                    : Text(
                        context.isIndonesian
                            ? 'Perbarui Data'
                            : 'Updating Data',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/custom_input.dart';
import 'package:hr/components/custom/custom_dropdown.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/data/models/peran_model.dart';
import 'package:hr/data/services/departemen_service.dart';
import 'package:hr/data/services/jabatan_service.dart';
import 'package:hr/data/services/peran_service.dart';
import 'package:hr/features/auth/login_viewmodels.dart/login_provider.dart';
import 'package:provider/provider.dart';

class KaryawanInput extends StatefulWidget {
  const KaryawanInput({super.key});

  @override
  State<KaryawanInput> createState() => _KaryawanInputState();
}

class _KaryawanInputState extends State<KaryawanInput> {
  // Controllers
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _gajiController = TextEditingController();
  final TextEditingController _npwpController = TextEditingController();
  final TextEditingController _bpjsKesController = TextEditingController();
  final TextEditingController _bpjsKetController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
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

  // Static dropdown data
  final List<String> _jenisKelaminList = ["Laki-laki", "Perempuan"];
  final List<String> _statusList = ["Menikah", "Belum Menikah"];

  @override
  void initState() {
    super.initState();
    _loadJabatan();
    _loadPeran();
    _loadDepartemen();
  }

  Future<void> _loadJabatan() async {
    try {
      final data = await JabatanService.fetchJabatan();
      setState(() {
        _jabatanList = data
            .map((j) => {
                  "id": j.id,
                  "nama_jabatan": j.namaJabatan,
                })
            .toList();
        _isLoadingJabatan = false;
      });
    } catch (e) {
      setState(() => _isLoadingJabatan = false);
      final message = context.isIndonesian
          ? "Gagal memuat jabatan: $e"
          : "Failed to load positions: $e";
      NotificationHelper.showTopNotification(
        context,
        message,
        isSuccess: false,
      );
    }
  }

  Future<void> _loadPeran() async {
    try {
      final data = await PeranService.fetchPeran();
      setState(() {
        _peranList = data;
        _isLoadingPeran = false;
      });
    } catch (e) {
      setState(() => _isLoadingPeran = false);
      final message = context.isIndonesian
          ? "Gagal memuat peran: $e"
          : "Failed to load roles: $e";
      NotificationHelper.showTopNotification(
        context,
        message,
        isSuccess: false,
      );
    }
  }

  Future<void> _loadDepartemen() async {
    try {
      final data = await DepartemenService.fetchDepartemen();
      setState(() {
        _departemenList = data
            .map((d) => {
                  "id": d.id,
                  "nama_departemen": d.namaDepartemen,
                })
            .toList();
        _isLoadingDepartemen = false;
      });
    } catch (e) {
      setState(() => _isLoadingDepartemen = false);
      final message = context.isIndonesian
          ? "Gagal memuat department: $e"
          : "Failed to load departments: $e";
      NotificationHelper.showTopNotification(
        context,
        message,
        isSuccess: false,
      );
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _gajiController.dispose();
    _npwpController.dispose();
    _bpjsKesController.dispose();
    _bpjsKetController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitData() async {
    if (_isLoading) return;

    // Validasi form
    if (_namaController.text.isEmpty ||
        _jabatanId == null ||
        _peranId == null ||
        _departemenId == null ||
        _gajiController.text.isEmpty ||
        _jenisKelamin == null ||
        _statusPernikahan == null ||
        _passwordController.text.isEmpty) {
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

    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      final response = await userProvider.createUser({
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
        "password": _passwordController.text.trim(),
      });

      if (response['success'] == false && response.containsKey('errors')) {
        final errors = response['errors'] as Map<String, dynamic>;
        final errorMessages =
            errors.values.expand((messages) => messages as List).join(', ');
        NotificationHelper.showTopNotification(
          context,
          errorMessages, // langsung pesan error tanpa field
          isSuccess: false,
        );
        return;
      }

      if (response['success'] == true) {
        NotificationHelper.showTopNotification(
          context,
          response['message'] ??
              (context.isIndonesian
                  ? "Karyawan berhasil ditambahkan"
                  : "Employee added successfully"),
          isSuccess: true,
        );
        Navigator.pop(context, true);
      } else {
        NotificationHelper.showTopNotification(
          context,
          response['message'] ??
              (context.isIndonesian
                  ? "Terjadi kesalahan"
                  : "An error occurred"),
          isSuccess: false,
        );
      }
    } catch (e) {
      NotificationHelper.showTopNotification(
        context,
        e.toString(),
        isSuccess: false,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputStyle = InputDecoration(
      hintStyle: TextStyle(color: AppColors.putih),
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

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.05,
        vertical: MediaQuery.of(context).size.height *
            (context.isMobile ? 0.05 : 0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomInputField(
            controller: _namaController,
            label: context.isIndonesian ? "Nama" : 'Name',
            hint: "",
            labelStyle: labelStyle,
            textStyle: textStyle,
            inputStyle: inputStyle,
          ),
          CustomDropDownField(
            label: context.isIndonesian ? 'Jabatan' : 'Position',
            hint: _isLoadingJabatan ? 'Memuat...' : '',
            items: _jabatanList
                .where((e) => e["nama_jabatan"] != null)
                .map((e) => e["nama_jabatan"] as String)
                .toList(),
            onChanged: (val) {
              final selected = _jabatanList.firstWhere(
                (e) => e["nama_jabatan"] == val,
                orElse: () => <String, Object>{},
              );
              _jabatanId = selected["id"] as int;
            },
            labelStyle: labelStyle,
            textStyle: textStyle,
            dropdownColor: AppColors.secondary,
            dropdownTextColor: AppColors.putih,
            dropdownIconColor: AppColors.putih,
            inputStyle: inputStyle,
          ),
          CustomDropDownField(
            label: context.isIndonesian ? 'Peran' : 'Role',
            hint: _isLoadingPeran ? 'Memuat...' : '',
            items: _peranList
                .where((e) => e.namaPeran.isNotEmpty)
                .map((e) => e.namaPeran)
                .toList(),
            onChanged: (val) {
              final selected = _peranList.firstWhere(
                (e) => e.namaPeran == val,
                orElse: () => PeranModel(id: 0, namaPeran: '', fitur: []),
              );
              _peranId = selected.id;
            },
            labelStyle: labelStyle,
            textStyle: textStyle,
            dropdownColor: AppColors.secondary,
            dropdownTextColor: AppColors.putih,
            dropdownIconColor: AppColors.putih,
            inputStyle: inputStyle,
          ),
          CustomDropDownField(
            label: 'Departemen',
            hint: _isLoadingDepartemen ? 'Memuat...' : '',
            items: _departemenList
                .where((e) => e["nama_departemen"] != null)
                .map((e) => e["nama_departemen"] as String)
                .toList(),
            onChanged: (val) {
              final selected = _departemenList.firstWhere(
                (e) => e["nama_departemen"] == val,
                orElse: () => <String, Object>{},
              );
              _departemenId = selected["id"] as int;
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
            label: context.isIndonesian ? "Gaji Per Hari" : 'Daily Salary',
            hint: "",
            labelStyle: labelStyle,
            textStyle: textStyle,
            inputStyle: inputStyle,
          ),
          CustomInputField(
            controller: _npwpController,
            label: "NPWP",
            hint: "",
            labelStyle: labelStyle,
            textStyle: textStyle,
            inputStyle: inputStyle,
          ),
          CustomInputField(
            controller: _bpjsKetController,
            label: "No. BPJS Ketenagakerjaan",
            hint: "",
            labelStyle: labelStyle,
            textStyle: textStyle,
            inputStyle: inputStyle,
          ),
          CustomInputField(
            controller: _bpjsKesController,
            label: "No. BPJS Kesehatan",
            hint: "",
            labelStyle: labelStyle,
            textStyle: textStyle,
            inputStyle: inputStyle,
          ),
          CustomPasswordField(
            controller: _passwordController,
            label: "Password HRIS Account",
            hint: context.isIndonesian ? "Masukkan password" : "Input password",
            labelStyle: labelStyle,
            textStyle: textStyle,
            inputStyle: inputStyle,
          ),
          CustomDropDownField(
            label: context.isIndonesian ? 'Jenis Kelamin' : 'Gender',
            hint: '',
            items: _jenisKelaminList,
            onChanged: (val) => _jenisKelamin = val,
            labelStyle: labelStyle,
            textStyle: textStyle,
            dropdownColor: AppColors.secondary,
            dropdownTextColor: AppColors.putih,
            dropdownIconColor: AppColors.putih,
            inputStyle: inputStyle,
          ),
          CustomDropDownField(
            label:
                context.isIndonesian ? 'Status Pernikahan' : 'Marriage Status',
            hint: '',
            items: _statusList,
            onChanged: (val) => _statusPernikahan = val,
            labelStyle: labelStyle,
            textStyle: textStyle,
            dropdownColor: AppColors.secondary,
            dropdownTextColor: AppColors.putih,
            dropdownIconColor: AppColors.putih,
            inputStyle: inputStyle,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F1F1F),
                padding:
                    EdgeInsets.symmetric(vertical: context.isMobile ? 18 : 25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.putih,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Submit',
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
    );
  }
}

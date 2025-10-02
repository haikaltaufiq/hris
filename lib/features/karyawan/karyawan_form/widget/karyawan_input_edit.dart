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
    _peranId = widget.user.peran.id;
    _departemenId = widget.user.departemen.id;
  }

  Future<void> _loadJabatan() async {
    try {
      final data = await JabatanService.fetchJabatan();
      if (mounted) {
        // ✅ Safety check
        setState(() {
          _jabatanList = data
              .map((j) => {"id": j.id, "nama_jabatan": j.namaJabatan})
              .toList();
          _isLoadingJabatan = false;
        });
      }
    } catch (e) {
      if (mounted) {
        // ✅ Safety check
        setState(() => _isLoadingJabatan = false);
        NotificationHelper.showTopNotification(
            context, "Gagal memuat jabatan: $e",
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
        NotificationHelper.showTopNotification(
            context, "Gagal memuat peran: $e",
            isSuccess: false);
      }
    }
  }

  Future<void> _loadDepartemen() async {
    try {
      final data = await DepartemenService.fetchDepartemen();
      if (mounted) {
        // ✅ Safety check
        setState(() {
          _departemenList = data
              .map((d) => {"id": d.id, "nama_departemen": d.namaDepartemen})
              .toList();
          _isLoadingDepartemen = false;
        });
      }
    } catch (e) {
      if (mounted) {
        // ✅ Safety check
        setState(() => _isLoadingDepartemen = false);
        NotificationHelper.showTopNotification(
            context, "Gagal memuat departemen: $e",
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

  // ✅ Safe dropdown hint helper tuntuk yang type string
  String _getSafeDropdownHintMap(bool isLoading, int? selectedId,
      List<Map<String, dynamic>> items, String key) {
    if (isLoading) return 'Memuat...';
    if (selectedId == null) return 'Pilih...';

    try {
      final selected = items.firstWhere(
        (e) => e['id'] == selectedId,
        orElse: () => <String, dynamic>{},
      );
      return selected.isNotEmpty ? selected[key].toString() : 'Pilih...';
    } catch (e) {
      return 'Pilih...';
    }
  }

  // ✅ Enhanced validation
  bool _validateForm() {
    if (_namaController.text.trim().isEmpty) {
      NotificationHelper.showTopNotification(context, "Nama tidak boleh kosong",
          isSuccess: false);
      return false;
    }

    if (_jabatanId == null) {
      NotificationHelper.showTopNotification(context, "Jabatan harus dipilih",
          isSuccess: false);
      return false;
    }

    if (_peranId == null) {
      NotificationHelper.showTopNotification(context, "Peran harus dipilih",
          isSuccess: false);
      return false;
    }

    if (_departemenId == null) {
      NotificationHelper.showTopNotification(
          context, "Departemen harus dipilih",
          isSuccess: false);
      return false;
    }

    if (_gajiController.text.trim().isEmpty) {
      NotificationHelper.showTopNotification(context, "Gaji tidak boleh kosong",
          isSuccess: false);
      return false;
    }

    // ✅ Validate gaji format
    final gaji = int.tryParse(_gajiController.text.trim());
    if (gaji == null || gaji <= 0) {
      NotificationHelper.showTopNotification(
          context, "Gaji harus berupa angka yang valid",
          isSuccess: false);
      return false;
    }

    if (_jenisKelamin == null) {
      NotificationHelper.showTopNotification(
          context, "Jenis kelamin harus dipilih",
          isSuccess: false);
      return false;
    }

    if (_statusPernikahan == null) {
      NotificationHelper.showTopNotification(
          context, "Status pernikahan harus dipilih",
          isSuccess: false);
      return false;
    }

    return true;
  }

  Future<void> _submitData() async {
    // ✅ Prevent multiple submissions
    if (_isSubmitting) return;

    if (!_validateForm()) return;

    setState(() => _isSubmitting = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      // pakai provider biar otomatis fetchUsers setelah update
      await userProvider.updateUser(
        widget.user.id,
        {
          "nama": _namaController.text.trim(),
          "peran_id": _peranId,
          "jabatan_id": _jabatanId,
          "departemen_id": _departemenId,
          "gaji_per_hari": int.parse(_gajiController.text.trim()),
          "npwp": _npwpController.text.trim(),
          "bpjs_kesehatan": _bpjsKesController.text.trim(),
          "bpjs_ketenagakerjaan": _bpjsKetController.text.trim(),
          "jenis_kelamin": _jenisKelamin,
          "status_pernikahan": _statusPernikahan,
        },
      );

      if (mounted) {
        NotificationHelper.showTopNotification(
          context,
          "Data karyawan berhasil diperbarui",
          isSuccess: true,
        );
        Navigator.pop(
            context, true); // true supaya halaman list refresh otomatis
      }
    } catch (e) {
      if (mounted) {
        if (e is Map<String, dynamic>) {
          final List<String> errorMessages = [];
          e.forEach((field, messages) {
            if (messages is List) {
              errorMessages.add("$field: ${messages.join(', ')}");
            }
          });

          for (String message in errorMessages) {
            NotificationHelper.showTopNotification(context, message,
                isSuccess: false);
          }
        } else {
          NotificationHelper.showTopNotification(
            context,
            "Gagal memperbarui data: $e",
            isSuccess: false,
          );
        }
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
              hint: _getSafeDropdownHintMap(
                _isLoadingJabatan,
                _jabatanId,
                _jabatanList,
                "nama_jabatan",
              ),
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
              label: 'Departemen *',
              hint: _getSafeDropdownHintMap(
                _isLoadingDepartemen,
                _departemenId,
                _departemenList,
                "nama_departemen",
              ),
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
              hint: context.isIndonesian
                  ? "Masukkan NPWP (opsional)"
                  : "Input NPWP (Optional)",
              labelStyle: labelStyle,
              textStyle: textStyle,
              inputStyle: inputStyle,
            ),

            CustomInputField(
              controller: _bpjsKetController,
              label: "No. BPJS Ketenagakerjaan",
              hint: context.isIndonesian
                  ? "Masukkan nomor BPJS Ketenagakerjaan (opsional)"
                  : "Optional",
              labelStyle: labelStyle,
              textStyle: textStyle,
              inputStyle: inputStyle,
            ),

            CustomInputField(
              controller: _bpjsKesController,
              label: "No. BPJS Kesehatan",
              hint: context.isIndonesian
                  ? "Masukkan nomor BPJS Kesehatan (opsional)"
                  : "Optional",
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
                          const SizedBox(width: 10),
                          Text(
                            context.isIndonesian
                                ? 'Memperbarui...'
                                : 'Updating...',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
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

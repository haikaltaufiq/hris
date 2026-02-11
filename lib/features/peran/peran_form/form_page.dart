import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/loading.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/data/models/fitur_model.dart';
import 'package:hr/data/models/peran_model.dart';
import 'package:hr/data/services/fitur_service.dart';
import 'package:hr/data/services/peran_service.dart';

class PeranFormPage extends StatefulWidget {
  final PeranModel? peran;
  const PeranFormPage({super.key, this.peran});

  @override
  State<PeranFormPage> createState() => _PeranFormPageState();
}

class _PeranFormPageState extends State<PeranFormPage> {
  late TextEditingController _namaController;
  late TextEditingController _searchController;
  List<Fitur> _allFitur = [];
  List<Fitur> _selectedFitur = [];
  bool _saving = false;
  bool _selectAll = false;

  // 🎯 DEFINISI HIERARKI FITUR
  final Map<String, FeatureRule> _featureRules = {
    // CUTI RULES
    'lihat_cuti_sendiri': FeatureRule(
      parent: 'lihat_cuti',
      siblings: ['lihat_semua_cuti'],
    ),
    'lihat_semua_cuti': FeatureRule(
      parent: 'lihat_cuti',
      siblings: ['lihat_cuti_sendiri'],
    ),
    'tambah_cuti': FeatureRule(parent: 'lihat_cuti'),
    'edit_cuti': FeatureRule(parent: 'lihat_cuti'),
    'hapus_cuti': FeatureRule(parent: 'lihat_cuti'),

    // LEMBUR RULES
    'lihat_lembur_sendiri': FeatureRule(
      parent: 'lihat_lembur',
      siblings: ['lihat_semua_lembur'],
    ),
    'lihat_semua_lembur': FeatureRule(
      parent: 'lihat_lembur',
      siblings: ['lihat_lembur_sendiri'],
    ),
    'tambah_lembur': FeatureRule(parent: 'lihat_lembur'),
    'edit_lembur': FeatureRule(parent: 'lihat_lembur'),
    'hapus_lembur': FeatureRule(parent: 'lihat_lembur'),

    // TUGAS RULES
    'lihat_tugas_sendiri': FeatureRule(
      parent: 'lihat_tugas',
      siblings: ['lihat_semua_tugas'],
    ),
    'lihat_semua_tugas': FeatureRule(
      parent: 'lihat_tugas',
      siblings: ['lihat_tugas_sendiri'],
    ),

    'tambah_tugas': FeatureRule(parent: 'lihat_tugas'),
    'edit_tugas': FeatureRule(parent: 'lihat_tugas'),
    'tambah_lampiran_tugas': FeatureRule(parent: 'lihat_tugas'),
    'hapus_tugas': FeatureRule(parent: 'lihat_tugas'),

    // ABSENSI RULES
    'lihat_absensi_sendiri': FeatureRule(
      parent: 'absensi',
      siblings: ['lihat_semua_absensi'],
    ),
    'lihat_semua_absensi': FeatureRule(
      parent: 'absensi',
      siblings: ['lihat_absensi_sendiri'],
    ),

    // LEMBUR APPROVAL RULES
    'approve_lembur_step2': FeatureRule(
      parent: 'approve_lembur',
      siblings: ['approve_lembur_step1'],
    ),
    'approve_lembur_step1': FeatureRule(
      parent: 'approve_lembur',
      siblings: ['approve_lembur_step2'],
    ),

    // CUTI APPROVAL RULES
    'approve_cuti_step2': FeatureRule(
      parent: 'approve_cuti',
      siblings: ['approve_cuti_step1'],
    ),
    'approve_cuti_step1': FeatureRule(
      parent: 'approve_cuti',
      siblings: ['approve_cuti_step2'],
    ),
  };

  // 🎯 FITUR YANG PERLU KONFIRMASI SAAT SUBMIT
  final Map<String, List<String>> _confirmationFeatures = {
    'lihat_cuti': ['lihat_cuti_sendiri', 'lihat_semua_cuti'],
    'lihat_lembur': ['lihat_lembur_sendiri', 'lihat_semua_lembur'],
    'lihat_tugas': ['lihat_tugas_sendiri', 'lihat_semua_tugas'],
    'absensi': ['lihat_absensi_sendiri', 'lihat_semua_absensi'],
    'approve_lembur': ['approve_lembur_step1', 'approve_lembur_step2'],
    'approve_cuti': ['approve_cuti_step1', 'approve_cuti_step2'],
  };

  // 🎯 PAKETAN FITUR
  final Map<String, List<String>> _fiturPackages = {
    'Admin Super': [
      'web',
      'lihat_lembur', //lembur
      'lihat_semua_lembur',
      'approve_lembur',
      'approve_lembur_step2',
      'decline_lembur',
      'lihat_cuti', //cuti
      'lihat_semua_cuti',
      'approve_cuti',
      'approve_cuti_step2',
      'decline_cuti',
      'lihat_tugas', //tugas
      'lihat_semua_tugas',
      'tambah_tugas',
      'edit_tugas',
      'hapus_tugas',
      'departemen', //departemen
      'peran', //peran
      'jabatan', //jabatan
      'karyawan', //karyawan
      'gaji', //gaji
      'potongan_gaji', //potongan gaji
      'kantor', //kantor
      'absensi',
      'lihat_semua_absensi',
      'log_aktifitas',
      'pengaturan',
      'denger',
      'ubah_status_tugas',
      'pengingat',
    ],
    'Admin Office': [
      'web',
      'lihat_lembur',
      'lihat_semua_lembur',
      'approve_lembur',
      'approve_lembur_step1',
      'decline_lembur',
      'lihat_cuti',
      'lihat_semua_cuti',
      'approve_cuti',
      'approve_cuti_step1',
      'decline_cuti',
      'lihat_tugas',
      'lihat_semua_tugas',
      'tambah_tugas',
      'edit_tugas',
      'ubah_status_tugas',
      'hapus_tugas',
      'gaji',
      'absensi',
      'lihat_semua_absensi',
      'pengaturan',
      'pengingat',
    ],
    'Technical': [
      'apk',
      'lihat_lembur',
      'lihat_lembur_sendiri',
      'tambah_lembur',
      'edit_lembur',
      'hapus_lembur',
      'lihat_cuti',
      'lihat_cuti_sendiri',
      'tambah_cuti',
      'edit_cuti',
      'hapus_cuti',
      'lihat_tugas',
      'lihat_tugas_sendiri',
      'tambah_lampiran_tugas',
      'absensi',
      'lihat_absensi_sendiri',
      'pengaturan',
    ],
  };

  @override
  void initState() {
    super.initState();
    _namaController =
        TextEditingController(text: widget.peran?.namaPeran ?? '');
    _selectedFitur = List.from(widget.peran?.fitur ?? []);
    _searchController = TextEditingController();
    _loadFitur();
  }

  Future<void> _loadFitur() async {
    try {
      _allFitur = await FiturService.fetchFitur();
      _updateSelectAllState();
      setState(() {});
    } catch (e) {
      debugPrint('Gagal load fitur: $e');
    }
  }

  List<Fitur> get filteredFitur {
    if (_searchController.text.isEmpty) return _allFitur;
    return _allFitur
        .where((f) => f.namaFitur
            .toLowerCase()
            .contains(_searchController.text.toLowerCase()))
        .toList();
  }

  void _updateSelectAllState() {
    _selectAll =
        _allFitur.isNotEmpty && _selectedFitur.length == _allFitur.length;
  }

  // 🎯 ENHANCED TOGGLE FITUR DENGAN HIERARKI
  void _toggleFitur(Fitur f, bool select) {
    setState(() {
      if (select) {
        if (!_selectedFitur.any((e) => e.id == f.id)) {
          _selectedFitur.add(f);
        }
        _applyFeatureRules(f.namaFitur, true);
      } else {
        _selectedFitur.removeWhere((e) => e.id == f.id);
        _applyFeatureRules(f.namaFitur, false);
      }
      _updateSelectAllState();
    });
  }

  // 🎯 APPLY FEATURE RULES
  void _applyFeatureRules(String featureName, bool isSelected) {
    final rule = _featureRules[featureName];
    if (rule == null) return;

    if (isSelected) {
      // Auto-check parent
      if (rule.parent != null) {
        final parentFitur = _allFitur.firstWhere(
          (f) => f.namaFitur == rule.parent,
          orElse: () => Fitur(id: 0, namaFitur: '', deskripsiFitur: ''),
        );
        if (parentFitur.id != 0 &&
            !_selectedFitur.any((e) => e.id == parentFitur.id)) {
          _selectedFitur.add(parentFitur);
        }
      }

      // Auto-uncheck siblings
      if (rule.siblings != null) {
        for (String siblingName in rule.siblings!) {
          _selectedFitur.removeWhere((f) => f.namaFitur == siblingName);
        }
      }
    }
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      if (value == true) {
        _selectedFitur = List.from(_allFitur);
        _selectAll = true;
      } else {
        _selectedFitur.clear();
        _selectAll = false;
      }
    });
  }

  void _selectPackage(String packageName) {
    final packageFeatures = _fiturPackages[packageName] ?? [];
    setState(() {
      _selectedFitur.clear();
      for (String featureName in packageFeatures) {
        final fitur = _allFitur.firstWhere(
          (f) => f.namaFitur.toLowerCase().contains(featureName.toLowerCase()),
          orElse: () => Fitur(id: 0, namaFitur: '', deskripsiFitur: ''),
        );
        if (fitur.id != 0 && !_selectedFitur.any((e) => e.id == fitur.id)) {
          _selectedFitur.add(fitur);
        }
      }
      _updateSelectAllState();
    });
  }

  // 🎯 CHECK KONFIRMASI SEBELUM SUBMIT
  Future<bool> _checkConfirmation() async {
    for (String parentFeature in _confirmationFeatures.keys) {
      final children = _confirmationFeatures[parentFeature]!;

      // Cek apakah parent ada tapi children tidak ada
      bool hasParent = _selectedFitur.any((f) => f.namaFitur == parentFeature);
      bool hasAnyChild = children
          .any((child) => _selectedFitur.any((f) => f.namaFitur == child));

      if (hasParent && !hasAnyChild) {
        // Show confirmation dialog
        String? selected =
            await _showConfirmationDialog(parentFeature, children);
        if (selected != null) {
          // Add selected child feature
          final childFitur = _allFitur.firstWhere(
            (f) => f.namaFitur == selected,
            orElse: () => Fitur(id: 0, namaFitur: '', deskripsiFitur: ''),
          );
          if (childFitur.id != 0) {
            setState(() {
              _selectedFitur.add(childFitur);
            });
          }
        } else {
          return false; // User cancelled
        }
      }
    }
    return true;
  }

  // 🎯 SHOW CONFIRMATION DIALOG
  Future<String?> _showConfirmationDialog(
      String parentFeature, List<String> options) async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.bg,
          title: Text(
            context.isIndonesian
                ? 'Pilih Akses untuk ${_getFeatureDisplayName(parentFeature)}'
                : 'Choose Access to ${_getFeatureDisplayName(parentFeature)}',
            style: TextStyle(color: AppColors.putih, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((option) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(option),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.putih,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      _getFeatureDisplayName(option),
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Batal', style: TextStyle(color: AppColors.putih)),
            ),
          ],
        );
      },
    );
  }

  // 🎯 GET DISPLAY NAME FOR FEATURES
  String _getFeatureDisplayName(String featureName) {
    final displayNames = {
      'lihat_cuti': 'Lihat Cuti',
      'lihat_cuti_sendiri': 'Lihat Cuti Sendiri',
      'lihat_semua_cuti': 'Lihat Semua Cuti',
      'lihat_lembur': 'Lihat Lembur',
      'lihat_lembur_sendiri': 'Lihat Lembur Sendiri',
      'lihat_semua_lembur': 'Lihat Semua Lembur',
      'lihat_tugas': 'Lihat Tugas',
      'lihat_tugas_sendiri': 'Lihat Tugas Sendiri',
      'lihat_semua_tugas': 'Lihat Semua Tugas',
      'absensi': 'Absensi',
      'lihat_absensi_sendiri': 'Lihat Absensi Sendiri',
      'lihat_semua_absensi': 'Lihat Semua Absensi',
    };
    return displayNames[featureName] ?? featureName;
  }

  Future<void> _savePeran() async {
    if (_namaController.text.isEmpty) return;

    bool confirmed = await _checkConfirmation();
    if (!confirmed) return;

    setState(() => _saving = true);

    try {
      String backendMsg;

      if (widget.peran == null) {
        backendMsg = await PeranService.createPeran(
          _namaController.text,
          _selectedFitur.map((e) => e.id).toList(),
        );
      } else {
        backendMsg = await PeranService.updatePeran(
          widget.peran!.id,
          _namaController.text,
          _selectedFitur.map((e) => e.id).toList(),
        );
      }

      _showSnackBar(backendMsg);
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => _saving = false);
      _showSnackBar('$e', isSuccess: false);
    }
  }

  void _showSnackBar(String msg, {bool isSuccess = true}) {
    NotificationHelper.showTopNotification(context, msg, isSuccess: isSuccess);
  }

  @override
  Widget build(BuildContext context) {
    // ================= Styles =================
    final inputStyle = InputDecoration(
      hintStyle: TextStyle(color: AppColors.putih.withOpacity(0.5)),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.grey),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.putih),
      ),
    );

    final labelStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: AppColors.putih,
      fontSize: 16,
    );

    final textStyle = TextStyle(
      color: AppColors.putih,
      fontSize: 14,
    );

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: context.isMobile
          ? AppBar(
              title: Text(widget.peran == null
                  ? context.isIndonesian
                      ? 'Tambah Peran'
                      : 'Add Role'
                  : context.isIndonesian
                      ? 'Edit Peran'
                      : 'Edit Role'),
              backgroundColor: AppColors.bg,
              titleTextStyle: TextStyle(
                color: AppColors.putih,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.poppins().fontFamily,
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                color: AppColors.putih,
                onPressed: () => Navigator.of(context).pop(),
              ),
              iconTheme: IconThemeData(
                color: AppColors.putih,
              ),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Nama Peran
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: TextField(
                controller: _namaController,
                style: textStyle,
                decoration: inputStyle.copyWith(
                  labelText: context.isIndonesian ? 'Nama Peran' : 'Role Name',
                  labelStyle: labelStyle,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Search Fitur Manual
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              cursorColor: AppColors.putih,
              style: TextStyle(color: AppColors.putih, fontSize: 14),
              decoration: InputDecoration(
                hintText: context.isIndonesian ? 'Cari fitur...' : 'Search...',
                hintStyle: TextStyle(
                    color: AppColors.putih.withOpacity(0.5), fontSize: 14),
                prefixIcon:
                    Icon(Icons.search, color: AppColors.putih.withOpacity(0.5)),
                filled: true,
                fillColor: AppColors.primary,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: AppColors.secondary),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Template Fitur
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.isIndonesian
                        ? 'Template Fitur:'
                        : 'Feature Femplate',
                    style: TextStyle(
                      color: AppColors.putih,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      bool isMobile = MediaQuery.of(context).size.width < 600;
                      if (isMobile) {
                        return ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text(
                                  context.isIndonesian
                                      ? 'Pilih Paket'
                                      : 'Choose',
                                  style: TextStyle(color: AppColors.putih),
                                ),
                                backgroundColor: AppColors.bg,
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children:
                                      _fiturPackages.keys.map((packageName) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          _selectPackage(packageName);
                                          Navigator.pop(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.secondary,
                                          foregroundColor: AppColors.putih,
                                          minimumSize:
                                              const Size(double.infinity, 40),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                        ),
                                        child: Text(
                                          packageName,
                                          style:
                                              TextStyle(color: AppColors.putih),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: AppColors.putih,
                            minimumSize: const Size(120, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                              context.isIndonesian ? 'Pilih Paket' : 'Choose'),
                        );
                      } else {
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _fiturPackages.keys.map((packageName) {
                            return ElevatedButton(
                              onPressed: () => _selectPackage(packageName),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                foregroundColor: AppColors.putih,
                                minimumSize: const Size(120, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                packageName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // Select All Checkbox
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.isIndonesian
                        ? 'Daftar Fitur (${_selectedFitur.length}/${_allFitur.length})'
                        : 'Features (${_selectedFitur.length}/${_allFitur.length})',
                    style: TextStyle(
                      color: AppColors.putih,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Checkbox(
                      value: _selectAll,
                      activeColor: AppColors.secondary,
                      checkColor: AppColors.putih,
                      onChanged: _toggleSelectAll,
                    ),
                  ),
                ],
              ),
            ),

            // List Fitur
            Expanded(
              child: () {
                if (_allFitur.isEmpty) {
                  return const Center(child: LoadingWidget());
                } else if (filteredFitur.isEmpty) {
                  return Center(
                    child: Text(
                      context.isIndonesian
                          ? 'Tidak ada fitur ditemukan'
                          : 'No Features available',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: ListView.builder(
                      itemCount: filteredFitur.length,
                      itemBuilder: (_, index) {
                        final f = filteredFitur[index];
                        final selected =
                            _selectedFitur.any((e) => e.id == f.id);
                        return CheckboxListTile(
                          activeColor: AppColors.secondary,
                          checkColor: AppColors.putih,
                          title: Text(formatFeatureDisplayName(f.namaFitur),
                              style: textStyle),
                          subtitle: Text(f.deskripsiFitur,
                              style: textStyle.copyWith(
                                  color: AppColors.putih.withOpacity(0.6))),
                          value: selected,
                          onChanged: (val) => _toggleFitur(f, val ?? false),
                        );
                      },
                    ),
                  );
                }
              }(),
            ),

            const SizedBox(height: 16),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _savePeran,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F1F1F),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _saving
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        widget.peran == null
                            ? context.isIndonesian
                                ? 'Simpan Peran'
                                : 'Save'
                            : context.isIndonesian
                                ? 'Update Peran'
                                : 'Update',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🎯 CLASS UNTUK DEFINISI ATURAN FITUR
class FeatureRule {
  final String? parent;
  final List<String>? siblings;

  FeatureRule({this.parent, this.siblings});
}

String formatFeatureDisplayName(String value) {
  if (value.isEmpty) return '';
  return value
      .split('_')
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
}

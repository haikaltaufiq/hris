import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/loading.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
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

  void _toggleFitur(Fitur f, bool select) {
    setState(() {
      if (select) {
        if (!_selectedFitur.any((e) => e.id == f.id)) _selectedFitur.add(f);
      } else {
        _selectedFitur.removeWhere((e) => e.id == f.id);
      }
    });
  }

  Future<void> _savePeran() async {
    if (_namaController.text.isEmpty) return;
    setState(() => _saving = true);

    try {
      if (widget.peran == null) {
        await PeranService.createPeran(
            _namaController.text, _selectedFitur.map((e) => e.id).toList());
        _showSnackBar('Peran berhasil ditambahkan');
      } else {
        await PeranService.updatePeran(widget.peran!.id, _namaController.text,
            _selectedFitur.map((e) => e.id).toList());
        _showSnackBar('Peran berhasil diperbarui');
      }
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => _saving = false);
      _showSnackBar('Gagal menyimpan: $e');
    }
  }

  void _showSnackBar(String msg) {
    NotificationHelper.showTopNotification(context, msg);
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
              title: Text(widget.peran == null ? 'Tambah Peran' : 'Edit Peran'),
              backgroundColor: AppColors.bg,
              titleTextStyle: TextStyle(
                color: AppColors.putih,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.poppins().fontFamily,
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
                  labelText: 'Nama Peran',
                  labelStyle: labelStyle,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ================== Search Fitur Manual ==================
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              cursorColor: AppColors.putih,
              style: TextStyle(color: AppColors.putih, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Cari fitur...',
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

            // List Fitur
            Expanded(
              child: () {
                if (_allFitur.isEmpty) {
                  return const Center(child: LoadingWidget());
                } else if (filteredFitur.isEmpty) {
                  return const Center(
                    child: Text(
                      'Tidak ada fitur ditemukan',
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
                          title: Text(f.namaFitur, style: textStyle),
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

            // Select All / Clear All
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        setState(() => _selectedFitur = List.from(_allFitur)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: Text(
                      'Pilih Semua',
                      style: TextStyle(
                          color: AppColors.putih,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedFitur.isEmpty
                            ? Colors.grey
                            : Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18)),
                    onPressed: _selectedFitur.isEmpty
                        ? null
                        : () => setState(() => _selectedFitur.clear()),
                    child: Text(
                      'Hapus Semua',
                      style: TextStyle(
                          color: AppColors.putih,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                ),
              ],
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
                        widget.peran == null ? 'Simpan Peran' : 'Update Peran',
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

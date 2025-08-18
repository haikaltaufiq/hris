import 'package:flutter/material.dart';
import 'package:hr/data/models/cuti_model.dart';
import 'package:hr/data/services/cuti_service.dart';

class CutiProvider with ChangeNotifier {
  List<CutiModel> _cutiList = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CutiModel> get cutiList => _cutiList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<CutiModel> filteredCutiList = [];
  String _currentSearch = '';

  /// Ambil semua data cuti dari API
  Future<void> fetchCuti() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _cutiList = await CutiService.fetchCuti();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Searching fitur
  void filterCuti(String query) {
    if (query.isEmpty) {
      filteredCutiList.clear();
    } else {
      final lowerQuery = query.toLowerCase();
      filteredCutiList = cutiList.where((cuti) {
        final namaKaryawan = (cuti.user['nama'] ?? '').toString().toLowerCase();
        return namaKaryawan.contains(lowerQuery) ||
            cuti.alasan.toLowerCase().contains(lowerQuery) ||
            cuti.tipe_cuti.toLowerCase().contains(lowerQuery) ||
            cuti.status.toLowerCase().contains(lowerQuery) ||
            cuti.tanggal_mulai.toLowerCase().contains(lowerQuery) ||
            cuti.tanggal_selesai.toLowerCase().contains(lowerQuery);
      }).toList();
    }
    notifyListeners();
  }

  /// Tambah cuti baru
  Future<bool> createCuti({
    required String nama,
    required String tipeCuti,
    required String tanggalMulai,
    required String tanggalSelesai,
    required String alasan,
  }) async {
    final success = await CutiService.createCuti(
      nama: nama,
      tipeCuti: tipeCuti,
      tanggalMulai: tanggalMulai,
      tanggalSelesai: tanggalSelesai,
      alasan: alasan,
    );

    if (success) {
      await fetchCuti(); // refresh data
    }

    return success;
  }

  /// Edit cuti
  Future<Map<String, dynamic>> editCuti({
    required int id,
    required String nama,
    required String tipeCuti,
    required String tanggalMulai,
    required String tanggalSelesai,
    required String alasan,
  }) async {
    final result = await CutiService.editCuti(
      id: id,
      nama: nama,
      tipeCuti: tipeCuti,
      tanggalMulai: tanggalMulai,
      tanggalSelesai: tanggalSelesai,
      alasan: alasan,
    );

    if (result['success'] == true) {
      await fetchCuti(); // refresh data
    }

    return result;
  }

  /// Hapus cuti
  Future<String> deleteCuti(int id, String currentSearch) async {
    final result = await CutiService.deleteCuti(id);
    await fetchCuti();
    filterCuti(_currentSearch);
    return result['message'] ?? 'Tidak ada pesan';
  }

  /// Approve cuti
  Future<String?> approveCuti(int id, String currentSearch) async {
    final message = await CutiService.approveCuti(id);
    await fetchCuti();
    filterCuti(_currentSearch);
    return message;
  }

  /// Decline cuti
  Future<String?> declineCuti(int id, String currentSearch) async {
    final message = await CutiService.declineCuti(id);
    await fetchCuti();
    filterCuti(_currentSearch);

    return message;
  }

  /// Approve cuti (tetap bisa pakai onApprove callback)
  Future<void> approve(Future<void> Function()? onApprove, {int? id}) async {
    if (onApprove != null) await onApprove(); // panggil callback UI dulu

    if (id != null) {
      await CutiService.approveCuti(id); // update di backend
      await fetchCuti(); // refresh cuti utama
      // apply filter lagi jika ada search aktif
      if (filteredCutiList.isNotEmpty) filterCuti('');
    }
  }

  /// Decline cuti (tetap bisa pakai onDecline callback)
  Future<void> decline(Future<void> Function()? onDecline, {int? id}) async {
    if (onDecline != null) await onDecline();

    if (id != null) {
      await CutiService.declineCuti(id);
      await fetchCuti();
      if (filteredCutiList.isNotEmpty) filterCuti('');
    }
  }

  /// Delete cuti (tetap bisa pakai onDelete callback)
  void delete(VoidCallback? onDelete, {int? id}) {
    if (onDelete != null) onDelete();

    if (id != null) {
      CutiService.deleteCuti(id).then((_) async {
        await fetchCuti();
        if (filteredCutiList.isNotEmpty) filterCuti('');
      });
    }
  }
}

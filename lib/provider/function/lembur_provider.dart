import 'package:flutter/material.dart';
import 'package:hr/data/models/lembur_model.dart';
import 'package:hr/data/services/lembur_service.dart';

class LemburProvider extends ChangeNotifier {
  List<LemburModel> _lemburList = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<LemburModel> get lemburList => _lemburList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<LemburModel> filteredLemburList = [];
  String _currentSearch = '';

  // Fetch semua lembur
  Future<void> fetchLembur() async {
    _isLoading = true;
    notifyListeners();

    try {
      _lemburList = await LemburService.fetchLembur();
    } catch (e) {
      print('Error fetch lembur: $e');
      _lemburList = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Searching fitur
  void filterLembur(String query) {
    if (query.isEmpty) {
      filteredLemburList.clear();
    } else {
      final lowerQuery = query.toLowerCase();
      filteredLemburList = lemburList.where((lembur) {
        return lembur.searchableFields.any(
          (field) => field.toLowerCase().contains(lowerQuery),
        );
      }).toList();
    }
    notifyListeners();
  }

  // Create lembur
  Future<bool> createLembur({
    required String tanggal,
    required String jamMulai,
    required String jamSelesai,
    required String deskripsi,
  }) async {
    final success = await LemburService.createLembur(
      tanggal: tanggal,
      jamMulai: jamMulai,
      jamSelesai: jamSelesai,
      deskripsi: deskripsi,
    );

    if (success) {
      await fetchLembur(); // Refresh list setelah create
    }
    return success;
  }

  // Edit lembur
  Future<Map<String, dynamic>> editLembur({
    required int id,
    required String tanggal,
    required String jamMulai,
    required String jamSelesai,
    required String deskripsi,
  }) async {
    final result = await LemburService.editLembur(
      id: id,
      tanggal: tanggal,
      jamMulai: jamMulai,
      jamSelesai: jamSelesai,
      deskripsi: deskripsi,
    );

    if (result['success'] == true) {
      await fetchLembur(); // Refresh list setelah edit
    }

    return result;
  }

  // Delete lembur
  Future<String?> deleteLembur(int id, String currentSearch) async {
    final result = await LemburService.deleteLembur(id);
    await fetchLembur(); // Refresh list setelah delete
    filterLembur(_currentSearch);
    return result['message'];
  }

  // Approve lembur
  Future<String?> approveLembur(int id, String currentSearch) async {
    final message = await LemburService.approveLembur(id);
    await fetchLembur(); // Refresh list setelah approve
    filterLembur(_currentSearch);
    return message;
  }

  // Decline lembur
  Future<String?> declineLembur(int id, String currentSearch) async {
    final message = await LemburService.declineLembur(id);
    await fetchLembur(); // Refresh list setelah decline
    filterLembur(_currentSearch);
    return message;
  }

  void setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Approve cuti (tetap bisa pakai onApprove callback)
  Future<void> approve(Future<void> Function()? onApprove, {int? id}) async {
    if (onApprove != null) await onApprove(); // panggil callback UI dulu

    if (id != null) {
      await LemburService.approveLembur(id); // update di backend
      await fetchLembur(); // refresh cuti utama
      // apply filter lagi jika ada search aktif
      if (filteredLemburList.isNotEmpty) filterLembur('');
    }
  }

  /// Decline cuti (tetap bisa pakai onDecline callback)
  Future<void> decline(Future<void> Function()? onDecline, {int? id}) async {
    if (onDecline != null) await onDecline();

    if (id != null) {
      await LemburService.declineLembur(id);
      await fetchLembur();
      if (filteredLemburList.isNotEmpty) filterLembur('');
    }
  }

  /// Delete cuti (tetap bisa pakai onDelete callback)
  void delete(VoidCallback? onDelete, {int? id}) {
    if (onDelete != null) onDelete();

    if (id != null) {
      LemburService.deleteLembur(id).then((_) async {
        await fetchLembur();
        if (filteredLemburList.isNotEmpty) filterLembur('');
      });
    }
  }
}

import 'package:flutter/material.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/data/models/jabatan_model.dart';
import 'package:hr/data/services/jabatan_service.dart';

class JabatanViewModel extends ChangeNotifier {
  List<JabatanModel> _jabatanList = [];
  List<JabatanModel> _filteredList = [];
  bool _isLoading = false;

  List<JabatanModel> get jabatanList =>
      _filteredList.isEmpty ? _jabatanList : _filteredList;

  bool get isLoading => _isLoading;

  Future<void> fetchJabatan(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      _jabatanList = await JabatanService.fetchJabatan();
      _filteredList.clear();
    } catch (e) {
      NotificationHelper.showTopNotification(context, 'Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createJabatan(BuildContext context, String namaJabatan) async {
    if (namaJabatan.trim().isEmpty) {
      NotificationHelper.showTopNotification(
          context, 'Nama jabatan tidak boleh kosong');
      return;
    }

    try {
      final result =
          await JabatanService.createJabatan(namaJabatan: namaJabatan);

      if (result['success']) {
        NotificationHelper.showTopNotification(context, result['message'],
            isSuccess: true);
        await fetchJabatan(context);
      } else {
        NotificationHelper.showTopNotification(context, result['message']);
      }
    } catch (e) {
      NotificationHelper.showTopNotification(context, 'Error: $e');
    }
  }

  Future<void> updateJabatan(
      BuildContext context, int id, String namaJabatan) async {
    if (namaJabatan.trim().isEmpty) {
      NotificationHelper.showTopNotification(
          context, 'Nama jabatan tidak boleh kosong');
      return;
    }

    try {
      final result =
          await JabatanService.updateJabatan(id: id, namaJabatan: namaJabatan);

      if (result['success']) {
        NotificationHelper.showTopNotification(context, result['message'],
            isSuccess: true);
        await fetchJabatan(context);
      } else {
        NotificationHelper.showTopNotification(context, result['message']);
      }
    } catch (e) {
      NotificationHelper.showTopNotification(context, 'Error: $e');
    }
  }

  Future<void> deleteJabatan(BuildContext context, int id) async {
    try {
      final result = await JabatanService.deleteJabatan(id);
      if (result['success']) {
        NotificationHelper.showTopNotification(context, result['message'],
            isSuccess: true);
        await fetchJabatan(context);
      } else {
        NotificationHelper.showTopNotification(context, result['message']);
      }
    } catch (e) {
      NotificationHelper.showTopNotification(context, 'Error: $e');
    }
  }

  // 🔎 Searching
  void search(String keyword) {
    if (keyword.isEmpty) {
      _filteredList.clear();
    } else {
      _filteredList = _jabatanList
          .where((e) =>
              e.namaJabatan.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void clearSearch() {
    _filteredList.clear();
    notifyListeners();
  }
}

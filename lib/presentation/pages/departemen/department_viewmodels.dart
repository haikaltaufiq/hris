import 'package:flutter/material.dart';
import 'package:hr/data/models/departemen_model.dart';
import 'package:hr/data/services/departemen_service.dart';

class DepartmentViewModel extends ChangeNotifier {
  List<DepartemenModel> _departemenList = [];
  List<DepartemenModel> _filteredList = [];
  bool _isLoading = false;

  List<DepartemenModel> get departemenList =>
      _filteredList.isEmpty ? _departemenList : _filteredList;

  bool get isLoading => _isLoading;

  /// Fetch awal data
  Future<void> fetchDepartemen() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await DepartemenService.fetchDepartemen();
      _departemenList = data;
      _filteredList = [];
    } catch (e) {
      _departemenList = [];
      _filteredList = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Create departemen
  Future<Map<String, dynamic>> createDepartemen(String nama) async {
    final result =
        await DepartemenService.createDepartemen(namaDepartemen: nama);
    if (result['success']) {
      await fetchDepartemen();
    }
    return result;
  }

  /// Update departemen
  Future<Map<String, dynamic>> updateDepartemen(int id, String nama) async {
    final result = await DepartemenService.updateDepartemen(
      id: id,
      namaDepartemen: nama,
    );
    if (result['success']) {
      await fetchDepartemen();
    }
    return result;
  }

  /// Delete departemen
  Future<Map<String, dynamic>> deleteDepartemen(int id) async {
    final result = await DepartemenService.deleteDepartemen(id);
    if (result['success']) {
      await fetchDepartemen();
    }
    return result;
  }

  /// Searching
  void searchDepartemen(String query) {
    if (query.isEmpty) {
      _filteredList = [];
    } else {
      _filteredList = _departemenList
          .where((d) =>
              d.namaDepartemen.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }
}

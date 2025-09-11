import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hr/data/models/departemen_model.dart';
import 'package:hr/data/services/departemen_service.dart';

class DepartmentViewModel extends ChangeNotifier {
  List<DepartemenModel> _departemenList = [];
  List<DepartemenModel> _filteredList = [];

  bool _isLoading = false;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Public getter untuk list departemen
  List<DepartemenModel> get departemenList =>
      _filteredList.isEmpty ? _departemenList : _filteredList;

  // Kalau mau filtered list terpisah
  List<DepartemenModel> get filteredList => _filteredList;

  bool get isLoading => _isLoading;
  
  final _departemenBox = Hive.box('department');
  bool _hasCache = false;
  bool get hasCache => _hasCache;

  /// Load cache immediately (synchronous)
  void loadCacheFirst() {
    try {
      final hasCache = _departemenBox.containsKey('departemen_list');
      if (hasCache) {
        final cached = _departemenBox.get('departemen_list') as List;
        if (cached.isNotEmpty) {
          _departemenList = cached
              .map((json) =>
                  DepartemenModel.fromJson(Map<String, dynamic>.from(json)))
              .toList();
          _hasCache = true;
          notifyListeners(); // Update UI immediately
          print('✅ Cache loaded: ${_departemenList.length} items');
        }
      }
    } catch (e) {
      print('❌ Error loading cache: $e');
    }
  }

  /// Fetch awal data
  Future<void> fetchDepartemen({bool forceRefresh = false}) async {
    print('🔄 fetchDepartemen called - forceRefresh: $forceRefresh');

    // Load cache first if not force refresh
    if (!forceRefresh && _departemenList.isEmpty) {
      loadCacheFirst();
    }

    _isLoading = true;
    notifyListeners();

    try {
      print('🌐 Calling API...');
      final apiData = await DepartemenService.fetchDepartemen();
      print('✅ API success: ${apiData.length} items');

      _departemenList = apiData;
      _filteredList.clear();
      _errorMessage = null;

      // Save to cache
      await _departemenBox.put(
        'departemen_list',
        _departemenList.map((c) => c.toJson()).toList(),
      );
      print('💾 Cache saved');

      _hasCache = true;
    } catch (e) {
      print('❌ API Error: $e');
      _errorMessage = e.toString();

      // If no data and cache exists, load cache
      if (_departemenList.isEmpty) {
        loadCacheFirst();
      }
    }

    _isLoading = false;
    notifyListeners();
    print('🏁 fetchDepartemen completed - items: ${_departemenList.length}');
  }

  /// Create departemen
  Future<Map<String, dynamic>> createDepartemen(String nama) async {
    final result =
        await DepartemenService.createDepartemen(namaDepartemen: nama);
    if (result['success']) {
      await fetchDepartemen(forceRefresh: true);
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
      await fetchDepartemen(forceRefresh: true);
    }
    return result;
  }

  /// Delete departemen
  Future<Map<String, dynamic>> deleteDepartemen(int id) async {
    final result = await DepartemenService.deleteDepartemen(id);
    if (result['success']) {
      await fetchDepartemen(forceRefresh: true);
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

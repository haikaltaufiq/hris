import 'package:flutter/material.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/data/models/jabatan_model.dart';
import 'package:hr/data/services/jabatan_service.dart';
import 'package:hive/hive.dart';

class JabatanViewModel extends ChangeNotifier {
  List<JabatanModel> _jabatanList = [];
  List<JabatanModel> _filteredList = [];
  bool _isLoading = false;

  List<JabatanModel> get jabatanList =>
      _filteredList.isEmpty ? _jabatanList : _filteredList;

  bool get isLoading => _isLoading;

  final _jabatanBox = Hive.box('jabatan');
  bool _hasCache = false;
  bool get hasCache => _hasCache;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Load cache immediately (synchronous)
  void loadCacheFirst() {
    try {
      final hasCache = _jabatanBox.containsKey('jabatan_list');
      if (hasCache) {
        final cached = _jabatanBox.get('jabatan_list') as List;
        if (cached.isNotEmpty) {
          _jabatanList = cached
              .map((json) =>
                  JabatanModel.fromJson(Map<String, dynamic>.from(json)))
              .toList();
          _hasCache = true;
          notifyListeners(); // Update UI immediately
          print('✅ Cache loaded: ${_jabatanList.length} items');
        }
      }
    } catch (e) {
      print('❌ Error loading cache: $e');
    }
  }

  /// Fetch awal data
  Future<void> fetchJabatan({bool forceRefresh = false}) async {
    print('🔄 fetchJabatan called - forceRefresh: $forceRefresh');

    // Load cache first if not force refresh
    if (!forceRefresh && _jabatanList.isEmpty) {
      loadCacheFirst();
    }

    _isLoading = true;
    notifyListeners();

    try {
      print('🌐 Calling API...');
      final apiData = await JabatanService.fetchJabatan();
      print('✅ API success: ${apiData.length} items');

      _jabatanList = apiData;
      _filteredList.clear();
      _errorMessage = null;

      // Save to cache
      await _jabatanBox.put(
        'jabatan_list',
        _jabatanList.map((c) => c.toJson()).toList(),
      );
      print('💾 Cache saved');

      _hasCache = true;
    } catch (e) {
      print('❌ API Error: $e');
      _errorMessage = e.toString();

      // If no data and cache exists, load cache
      if (_jabatanList.isEmpty) {
        loadCacheFirst();
      }
    }

    _isLoading = false;
    notifyListeners();
    print('🏁 fetchJabatan completed - items: ${_jabatanList.length}');
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
        await fetchJabatan(forceRefresh: true);
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
        await fetchJabatan(forceRefresh: true);
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
        await fetchJabatan(forceRefresh: true);
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

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hr/data/models/peran_model.dart';
import 'package:hr/data/services/peran_service.dart';

class PeranViewModel extends ChangeNotifier {
  final _peranBox = Hive.box('peran');

  List<PeranModel> _peranList = [];
  List<PeranModel> get peranList => _peranList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _hasCache = false;
  bool get hasCache => _hasCache;
  String _currentSortField = 'terbaru';
  String get currentSortField => _currentSortField;

// ================= SORTING ================= //
  void sortPeran(String sortBy) {
    _currentSortField = sortBy;

    if (_peranList.isEmpty) return;

    try {
      switch (sortBy) {
        case 'terbaru':
          _peranList.sort((a, b) => (b.id).compareTo(a.id));
          break;
        case 'terlama':
          _peranList.sort((a, b) => (a.id).compareTo(b.id));
          break;
      }
    } catch (e) {
      // print(' Sort error: $e');
    }

    notifyListeners();
  }

  // ================= SERVICE WRAPPER ================= //

  /// Load cache segera (synchronous)
  void loadCacheFirst() {
    try {
      final hasCache = _peranBox.containsKey('peran_list');
      if (hasCache) {
        final cached = _peranBox.get('peran_list') as List;
        if (cached.isNotEmpty) {
          _peranList = cached
              .map((json) =>
                  PeranModel.fromJson(Map<String, dynamic>.from(json)))
              .toList();
          _hasCache = true;
          notifyListeners(); // Update UI segera
          // print(' Cache loaded: ${_peranList.length} items');
        }
      }
    } catch (e) {
      // print(' Error loading cache: $e');
    }
  }

  /// Fetch daftar peran
  Future<void> fetchPeran({bool forceRefresh = false}) async {
    // print(' fetchPeran called - forceRefresh: $forceRefresh');

    // Load cache dulu kalau gak force refresh
    if (!forceRefresh && _peranList.isEmpty) {
      loadCacheFirst();
    }

    _isLoading = true;
    notifyListeners();

    try {
      // print(' Calling API...');
      final apiData = await PeranService.fetchPeran();
      // print(' API success: ${apiData.length} items');

      _peranList = apiData;
      sortPeran('terbaru');

      _errorMessage = null;

      // Save ke cache
      await _peranBox.put(
        'peran_list',
        _peranList.map((c) => c.toJson()).toList(),
      );
      // print(' Cache saved');

      _hasCache = true;
    } catch (e) {
      // print(' API Error: $e');
      _errorMessage = e.toString();

      // Kalau gak ada data dan cache ada, load cache
      if (_peranList.isEmpty) {
        loadCacheFirst();
      }
    }

    _isLoading = false;
    notifyListeners();
    // print(' fetchPeran completed - items: ${_peranList.length}');
  }

  /// Tambah peran
  Future<void> createPeran(String namaPeran, List<int> fiturIds) async {
    _isLoading = true;
    notifyListeners();
    try {
      final newPeran = await PeranService.createPeran(namaPeran, fiturIds);
      _peranList.add(newPeran);

      // Update cache
      await _peranBox.put(
        'peran_list',
        _peranList.map((c) => c.toJson()).toList(),
      );

      notifyListeners();
      // print(' Peran created: ${newPeran.namaPeran}');
    } catch (e) {
      // print(' Create error: $e');
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update peran
  Future<void> updatePeran(int id, String namaPeran, List<int> fiturIds) async {
    _isLoading = true;
    notifyListeners();
    try {
      final updatedPeran =
          await PeranService.updatePeran(id, namaPeran, fiturIds);

      final index = _peranList.indexWhere((p) => p.id == id);
      if (index != -1) _peranList[index] = updatedPeran;

      // Update cache
      await _peranBox.put(
        'peran_list',
        _peranList.map((c) => c.toJson()).toList(),
      );

      notifyListeners();
      // print(' Peran updated: ${updatedPeran.namaPeran}');
    } catch (e) {
      // print(' Update error: $e');
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Hapus peran
  Future<void> deletePeran(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await PeranService.deletePeran(id);
      _peranList.removeWhere((p) => p.id == id);

      // Update cache
      await _peranBox.put(
        'peran_list',
        _peranList.map((c) => c.toJson()).toList(),
      );

      notifyListeners();
      // print(' Peran deleted - id: $id');
    } catch (e) {
      // print(' Delete error: $e');
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// 📂 lib/features/gaji/gaji_provider.dart
// ignore_for_file: avoid_print, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hr/data/models/gaji_model.dart';
import 'package:hr/data/services/gaji_service.dart';

class GajiProvider extends ChangeNotifier {
  // ================= STATE ================= //
  List<GajiUser> _gajiList = [];
  List<GajiUser> _filteredList = [];

  bool _isLoading = false;
  String? _errorMessage;
  String _currentSearch = '';
  String _currentSortField = 'nama';

  final _gajiBox = Hive.box('gaji');
  bool _hasCache = false;

  // ================= GETTERS ================= //
  List<GajiUser> get gajiList =>
      _currentSearch.isEmpty ? _gajiList : _filteredList;

  bool get isLoading => _isLoading;
  String? get error => _errorMessage;
  bool get hasCache => _hasCache;
  String get currentSortField => _currentSortField;

  int get totalGaji => _gajiList.length;

  // ================= LOAD CACHE ================= //
  void loadCacheFirst() {
    try {
      final hasCache = _gajiBox.containsKey('gaji_list');
      if (hasCache) {
        final cached = _gajiBox.get('gaji_list') as List;
        if (cached.isNotEmpty) {
          _gajiList = cached
              .map((json) => GajiUser.fromJson(Map<String, dynamic>.from(json)))
              .toList();
          _hasCache = true;
          notifyListeners();
          print('✅ Cache loaded: ${_gajiList.length} items');
        }
      }
    } catch (e) {
      print('❌ Error loading cache: $e');
    }
  }

  // ================= FETCH DATA ================= //
  Future<void> fetchGaji({bool forceRefresh = false}) async {
    print('🔄 fetchGaji called - forceRefresh: $forceRefresh');

    if (!forceRefresh && _gajiList.isEmpty) {
      loadCacheFirst();
    }

    _isLoading = true;
    notifyListeners();

    try {
      print('🌐 Fetching gaji...');
      final apiData = await GajiService.fetchGaji();
      _gajiList = apiData;
      _filteredList.clear();
      _errorMessage = null;

      // save to cache
      await _gajiBox.put(
        'gaji_list',
        _gajiList.map((g) => g.toJson()).toList(),
      );

      _hasCache = true;
      print('💾 Cache updated (${_gajiList.length} items)');
    } catch (e) {
      print('❌ API Error: $e');
      _errorMessage = e.toString();

      if (_gajiList.isEmpty) {
        loadCacheFirst();
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // ================= SORTING ================= //
  void sortGaji(String sortBy) {
    _currentSortField = sortBy;
    notifyListeners(); // biar displayedList build ulang
  }

  // ================= SEARCH ================= //
  void searchGaji(String query) {
    _currentSearch = query.trim().toLowerCase();

    if (_currentSearch.isEmpty) {
      _filteredList = [];
    } else {
      _filteredList = _gajiList.where((gaji) {
        final nama = gaji.nama.toLowerCase();
        final status = gaji.status.toLowerCase();
        final gajiPokok = gaji.gajiPokok.toString();
        final gajiBersih = gaji.gajiBersih.toString();

        return nama.contains(_currentSearch) ||
            status.contains(_currentSearch) ||
            gajiPokok.contains(_currentSearch) ||
            gajiBersih.contains(_currentSearch);
      }).toList();
    }

    notifyListeners();
  }

  void clearSearch() {
    _currentSearch = '';
    _filteredList = [];
    notifyListeners();
  }

  // ================= DISPLAYED LIST ================= //
  List<GajiUser> get displayedList {
    List<GajiUser> data =
        _currentSearch.isEmpty ? [..._gajiList] : [..._filteredList];

    // Sorting sesuai field aktif
    switch (_currentSortField) {
      case 'terbaru':
        data.sort((a, b) => b.id.compareTo(a.id));
        break;

      case 'terlama':
        data.sort((a, b) => a.id.compareTo(b.id));
        break;

      case 'nama':
        data.sort(
            (a, b) => a.nama.toLowerCase().compareTo(b.nama.toLowerCase()));
        break;

      case 'status':
        data.sort((a, b) =>
            (a.status).toLowerCase().compareTo((b.status).toLowerCase()));
        break;
    }

    return data;
  }
}

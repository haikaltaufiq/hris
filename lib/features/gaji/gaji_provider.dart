import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hr/data/models/gaji_model.dart';
import 'package:hr/data/services/gaji_service.dart';

class GajiProvider extends ChangeNotifier {
  List<GajiUser> _gajiList = [];
  String _searchQuery = '';
  String _sortBy = 'nama';
  bool _ascending = true;
  bool _loading = false;
  String? _error;

  List<GajiUser> get gajiList => _gajiList;
  bool get isLoading => _loading;
  String? get error => _error;

  final _gajibox = Hive.box('gaji');
  bool _hasCache = false;
  bool get hasCache => _hasCache;

  /// Load cache immediately (synchronous)
  void loadCacheFirst() {
    try {
      final hasCache = _gajibox.containsKey('gaji_list');
      if (hasCache) {
        final cached = _gajibox.get('gaji_list') as List;
        if (cached.isNotEmpty) {
          _gajiList = cached
              .map((json) => GajiUser.fromJson(Map<String, dynamic>.from(json)))
              .toList();
          _hasCache = true;
          notifyListeners(); // Update UI immediately
          print('✅ Cache loaded: ${_gajiList.length} items');
        }
      }
    } catch (e) {
      print('❌ Error loading cache: $e');
    }
  }

  /// Fetch data dari API
  Future<void> fetchGaji({bool forceRefresh = false}) async {
    print('🔄 fetchGaji called - forceRefresh: $forceRefresh');

    // Load cache first if not force refresh
    if (!forceRefresh && _gajiList.isEmpty) {
      loadCacheFirst();
    }

    _loading = true;
    notifyListeners();

    try {
      print('🌐 Calling API...');
      final apiData = await GajiService.fetchGaji();
      print('✅ API success: ${apiData.length} items');

      _gajiList = apiData;
      _searchQuery = '';
      _error = null;
      // Save to cache
      await _gajibox.put(
        'gaji_list',
        _gajiList.map((c) => c.toJson()).toList(),
      );
      print('💾 Cache saved');

      _hasCache = true;
    } catch (e) {
      print('❌ API Error: $e');
      _error = e.toString();
      // If no data and cache exists, load cache
      if (_gajiList.isEmpty) {
        loadCacheFirst();
      }
    }

    _loading = false;
    notifyListeners();
    print('🏁 fetchGaji completed - items: ${_gajiList.length}');
  }

  /// Update search query
  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  /// Update sorting
  void setSorting(String sortBy, bool ascending) {
    _sortBy = sortBy;
    _ascending = ascending;
    notifyListeners();
  }

  /// List yang sudah di-filter + sort
  List<GajiUser> get displayedList {
    List<GajiUser> data = [..._gajiList];

    // filter by nama
    if (_searchQuery.isNotEmpty) {
      data = data
          .where((gaji) =>
              gaji.nama.toLowerCase().contains(_searchQuery) ||
              gaji.gajiPokok.toString().contains(_searchQuery) ||
              gaji.gajiBersih.toString().contains(_searchQuery))
          .toList();
    }

    // sort
    data.sort((a, b) {
      dynamic valueA, valueB;

      switch (_sortBy) {
        case 'nama':
          valueA = a.nama.toLowerCase();
          valueB = b.nama.toLowerCase();
          break;
        case 'gaji_per_hari':
          valueA = a.gajiPokok;
          valueB = b.gajiPokok;
          break;
        case 'gaji_bersih':
          valueA = a.gajiBersih;
          valueB = b.gajiBersih;
          break;
        default:
          valueA = a.nama.toLowerCase();
          valueB = b.nama.toLowerCase();
      }

      int result = 0;
      if (valueA is String && valueB is String) {
        result = valueA.compareTo(valueB);
      } else if (valueA is num && valueB is num) {
        result = valueA.compareTo(valueB);
      }

      return _ascending ? result : -result;
    });

    return data;
  }
}

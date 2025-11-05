import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hr/data/models/potongan_gaji.dart';
import 'package:hr/data/services/potongan_gaji_service.dart';

class PotonganGajiProvider extends ChangeNotifier {
  List<PotonganGajiModel> _potonganList = [];
  bool _isLoading = false;

  List<PotonganGajiModel> get potonganList => _potonganList;
  bool get isLoading => _isLoading;
  List<PotonganGajiModel> filteredPotonganGajiList = [];
  final String _currentSearch = '';

  final _potonganBox = Hive.box('potongan_gaji');
  bool _hasCache = false;
  bool get hasCache => _hasCache;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ================= Fetch =================

  /// Load cache immediately (synchronous)
  void loadCacheFirst() {
    try {
      final hasCache = _potonganBox.containsKey('potongan_list');
      if (hasCache) {
        final cached = _potonganBox.get('potongan_list') as List;
        if (cached.isNotEmpty) {
          _potonganList = cached
              .map((json) =>
                  PotonganGajiModel.fromJson(Map<String, dynamic>.from(json)))
              .toList();
          _hasCache = true;
          notifyListeners(); // Update UI immediately
          // print(' Cache loaded: ${_potonganList.length} items');
        }
      }
    } catch (e) {
      // print(' Error loading cache: $e');
    }
  }

  /// Fetch awal data
  Future<void> fetchPotonganGaji({bool forceRefresh = false}) async {
    // print(' fetchPotonganGaji called - forceRefresh: $forceRefresh');

    // Load cache first if not force refresh
    if (!forceRefresh && _potonganList.isEmpty) {
      loadCacheFirst();
    }

    _isLoading = true;
    notifyListeners();

    try {
      // print(' Calling API...');
      final apiData = await PotonganGajiService.fetchPotonganGaji();
      // print(' API success: ${apiData.length} items');

      _potonganList = apiData;
      filteredPotonganGajiList.clear();
      _errorMessage = null;

      // Save to cache
      await _potonganBox.put(
        'potongan_list',
        _potonganList.map((c) => c.toJson()).toList(),
      );
      // print(' Cache saved');

      _hasCache = true;
    } catch (e) {
      // print(' API Error: $e');
      _errorMessage = e.toString();

      // If no data and cache exists, load cache
      if (_potonganList.isEmpty) {
        loadCacheFirst();
      }
    }

    _isLoading = false;
    notifyListeners();
    // print(' fetchPotonganGaji completed - items: ${_potonganList.length}');
  }

  void filterPotonganGaji(String query) {
    if (query.isEmpty) {
      filteredPotonganGajiList.clear();
    } else {
      final lowerQuery = query.toLowerCase();
      filteredPotonganGajiList = potonganList.where((potongan) {
        final nama = (potongan.namaPotongan).toLowerCase();
        final nominal = potongan.nominal.toString().toLowerCase();
        return nama.contains(lowerQuery) || nominal.contains(lowerQuery);
      }).toList();
    }
    notifyListeners();
  }

  // ================= Create =================
  Future<void> createPotonganGaji(PotonganGajiModel potongan) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newPotongan =
          await PotonganGajiService.createPotonganGaji(potongan);
      _potonganList.add(newPotongan);
      await fetchPotonganGaji(forceRefresh: true);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================= Update =================
  Future<void> updatePotonganGaji(PotonganGajiModel potongan) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await PotonganGajiService.updatePotonganGaji(potongan);
      if (result['success'] == true) {
        final index = _potonganList.indexWhere((p) => p.id == potongan.id);
        if (index != -1) {
          _potonganList[index] = result['data'] as PotonganGajiModel;
        }
        await fetchPotonganGaji(forceRefresh: true);
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================= Delete =================
  Future<void> deletePotonganGaji(int id, String currentSearch) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await PotonganGajiService.deletePotonganGaji(id);
      await fetchPotonganGaji(forceRefresh: true);
      filterPotonganGaji(_currentSearch);
      if (success) {
        _potonganList.removeWhere((p) => p.id == id);
      } else {
        throw Exception("Gagal menghapus potongan gaji");
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

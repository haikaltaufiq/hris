import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hr/data/models/pengingat_model.dart';
import 'package:hr/data/services/pengingat_service.dart';

class PengingatViewModel extends ChangeNotifier {
  List<ReminderData> _pengingatList = [];
  List<ReminderData> _filteredList = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<ReminderData> get pengingatList => _pengingatList;
  List<ReminderData> get filteredList => _filteredList;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  final _pengingatBox = Hive.box('pengingat');
  bool _hasCache = false;
  bool get hasCache => _hasCache;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  String _currentSortField = 'terdekat';
  String get currentSortField => _currentSortField;

  // ================= SORTING ================= //
  void sortPengingat(String sortBy) {
    _currentSortField = sortBy;

    switch (sortBy) {
      case 'terdekat':
        // Urut dari tanggal jatuh tempo terdekat ke terjauh (ascending)
        _pengingatList.sort(
          (a, b) => a.tanggalJatuhTempo.compareTo(b.tanggalJatuhTempo),
        );
        break;

      case 'terlama':
        // Urut dari tanggal jatuh tempo terlama ke yang paling dekat (descending)
        _pengingatList.sort(
          (a, b) => b.tanggalJatuhTempo.compareTo(a.tanggalJatuhTempo),
        );
        break;
    }

    notifyListeners();
  }

  /// Load cache immediately (synchronous)
  void loadCacheFirst() {
    try {
      final hasCache = _pengingatBox.containsKey('pengingat_list');
      if (hasCache) {
        final cached = _pengingatBox.get('pengingat_list') as List;
        if (cached.isNotEmpty) {
          _pengingatList = cached
              .map((json) =>
                  ReminderData.fromJson(Map<String, dynamic>.from(json)))
              .toList();
          _hasCache = true;
          notifyListeners(); // Update UI immediately
          // print(' Cache loaded: ${_pengingatList.length} items');
        }
      }
    } catch (e) {
      // print(' Error loading cache: $e');
    }
  }

  /// Fetch awal data
  Future<void> fetchPengingat({bool forceRefresh = false}) async {
    // print(' fetchPengingat called - forceRefresh: $forceRefresh');

    // Load cache first if not force refresh
    if (!forceRefresh && _pengingatList.isEmpty) {
      loadCacheFirst();
    }

    _isLoading = true;
    notifyListeners();

    try {
      // print(' Calling API...');
      final apiData = await PengingatService.fetchPengingat();
      // print(' API success: ${apiData.length} items');

      _pengingatList = apiData;
      sortPengingat('terdekat'); // Default sort

      _filteredList.clear();
      _errorMessage = null;

      // Save to cache
      await _pengingatBox.put(
        'pengingat_list',
        _pengingatList.map((c) => c.toJson()).toList(),
      );
      // print(' Cache saved');

      _hasCache = true;
    } catch (e) {
      // print(' API Error: $e');
      _errorMessage = e.toString();

      // If no data and cache exists, load cache
      if (_pengingatList.isEmpty) {
        loadCacheFirst();
      }
    }

    _isLoading = false;
    notifyListeners();
    // print(' fetchPengingat completed - items: ${_pengingatList.length}');
  }

  /// Tambah pengingat
  Future<void> addPengingat(ReminderData reminder) async {
    try {
      final result = await PengingatService.createPengingat(reminder);

      if (result["success"] == true) {
        _pengingatList.add(result["data"] as ReminderData);
        _applyFilter();
        notifyListeners();
      } else {
        throw Exception(result["message"]);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error addPengingat: $e");
      }
    }
  }

  /// Update pengingat
  Future<void> updatePengingat(int id, ReminderData reminder) async {
    try {
      final result = await PengingatService.updatePengingat(id, reminder);

      if (result["success"] == true) {
        final index = _pengingatList.indexWhere((e) => e.id == id);
        if (index != -1) {
          _pengingatList[index] = result["data"] as ReminderData;
        }
        _applyFilter();
        notifyListeners();
      } else {
        throw Exception(result["message"]);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updatePengingat: $e");
      }
    }
  }

  /// Update status
  Future<void> updateStatus(int id, String newStatus) async {
    try {
      await PengingatService.updateStatus(id, newStatus);
      final index = _pengingatList.indexWhere((e) => e.id == id);
      if (index != -1) {
        final old = _pengingatList[index];
        _pengingatList[index] = ReminderData(
          id: old.id,
          judul: old.judul,
          deskripsi: old.deskripsi,
          status: newStatus,
          tanggalJatuhTempo: old.tanggalJatuhTempo,
          // isi semua field lain dari model ReminderData lo
        );
        _applyFilter();
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        // print("Error updateStatus: $e");
      }
    }
  }

  /// Hapus pengingat
  Future<void> deletePengingat(int id) async {
    try {
      await PengingatService.deletePengingat(id);
      _pengingatList.removeWhere((e) => e.id == id);
      _applyFilter();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        // print("Error deletePengingat: $e");
      }
    }
  }

  /// Set query search
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  /// Internal filter
  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredList = List.from(_pengingatList);
    } else {
      final lowerQuery = _searchQuery.toLowerCase();
      _filteredList = _pengingatList.where((reminder) {
        return (reminder.judul.toLowerCase().contains(lowerQuery)) ||
            (reminder.deskripsi.toLowerCase().contains(lowerQuery)) ||
            (reminder.status.toLowerCase().contains(lowerQuery));
      }).toList();
    }
  }
}

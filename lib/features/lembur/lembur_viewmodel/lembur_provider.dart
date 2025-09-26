import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
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
  final String _currentSearch = '';

  final _lemburBox = Hive.box('lembur');
  bool _hasCache = false;
  bool get hasCache => _hasCache;

  /// Load cache immediately (synchronous)
  void loadCacheFirst() {
    try {
      final hasCache = _lemburBox.containsKey('cuti_list');
      if (hasCache) {
        final cached = _lemburBox.get('cuti_list') as List;
        if (cached.isNotEmpty) {
          _lemburList = cached
              .map((json) =>
                  LemburModel.fromJson(Map<String, dynamic>.from(json)))
              .toList();
          _hasCache = true;
          notifyListeners(); // Update UI immediately
          print('✅ Cache loaded: ${_lemburList.length} items');
        }
      }
    } catch (e) {
      print('❌ Error loading cache: $e');
    }
  }

  // Fetch semua lembur
  Future<void> fetchLembur({bool forceRefresh = false}) async {
    print('🔄 fetchLembur called - forceRefresh: $forceRefresh');

    // Load cache first if not force refresh
    if (!forceRefresh && _lemburList.isEmpty) {
      loadCacheFirst();
    }

    _isLoading = true;
    notifyListeners();

    try {
      print('🌐 Calling API...');
      final apiData = await LemburService.fetchLembur();
      print('✅ API success: ${apiData.length} items');

      _lemburList = apiData;
      filteredLemburList.clear();
      _errorMessage = null;

      // Save to cache
      await _lemburBox.put(
        'lembur_list',
        _lemburList.map((c) => c.toJson()).toList(),
      );
      print('💾 Cache saved');

      _hasCache = true;
    } catch (e) {
      print('❌ API Error: $e');
      _errorMessage = e.toString();

      // If no data and cache exists, load cache
      if (_lemburList.isEmpty) {
        loadCacheFirst();
      }
    }

    _isLoading = false;
    notifyListeners();
    print('🏁 fetchLembur completed - items: ${_lemburList.length}');
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
  Future<Map<String, dynamic>> createLembur({
    required String tanggal,
    required String jamMulai,
    required String jamSelesai,
    required String deskripsi,
  }) async {
    final response = await LemburService.createLembur(
      tanggal: tanggal,
      jamMulai: jamMulai,
      jamSelesai: jamSelesai,
      deskripsi: deskripsi,
    );

    if (response['success'] == true) {
      await fetchLembur(forceRefresh: true); // Refresh list setelah create
    }

    return response; // langsung balikin Map biar UI bisa ambil message
  }

  // // Edit lembur
  // Future<Map<String, dynamic>> editLembur({
  //   required int id,
  //   required String tanggal,
  //   required String jamMulai,
  //   required String jamSelesai,
  //   required String deskripsi,
  // }) async {
  //   final result = await LemburService.editLembur(
  //     id: id,
  //     tanggal: tanggal,
  //     jamMulai: jamMulai,
  //     jamSelesai: jamSelesai,
  //     deskripsi: deskripsi,
  //   );

  //   if (result['success'] == true) {
  //     await fetchLembur(forceRefresh: true); // Refresh list setelah edit
  //   }

  //   return result;
  // }

  // // Delete lembur
  // Future<String?> deleteLembur(int id, String currentSearch) async {
  //   final result = await LemburService.deleteLembur(id);
  //   await fetchLembur(forceRefresh: true); // Refresh list setelah delete
  //   filterLembur(_currentSearch);
  //   return result['message'];
  // }

  // Approve lembur
  Future<String?> approveLembur(int id, String currentSearch) async {
    final message = await LemburService.approveLembur(id);
    await fetchLembur(forceRefresh: true); // Refresh list setelah approve
    filterLembur(_currentSearch);
    return message;
  }

  /// Decline lembur
  Future<String?> declineLembur(int id, String catatanPenolakan) async {
    final message = await LemburService.declineLembur(id, catatanPenolakan);
    await fetchLembur(forceRefresh: true); // Refresh list setelah decline
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
      await fetchLembur(forceRefresh: true); // refresh cuti utama
      // apply filter lagi jika ada search aktif
      if (filteredLemburList.isNotEmpty) filterLembur('');
    }
  }

  /// Decline dengan callback (opsional dari UI)
  Future<void> decline(Future<void> Function()? onDecline,
      {int? id, String? catatan_penolakan}) async {
    if (onDecline != null) await onDecline();

    if (id != null && catatan_penolakan != null) {
      await LemburService.declineLembur(id, catatan_penolakan);
      await fetchLembur(forceRefresh: true);
      if (filteredLemburList.isNotEmpty) filterLembur('');
    }
  }

  // /// Delete cuti (tetap bisa pakai onDelete callback)
  // void delete(VoidCallback? onDelete, {int? id}) {
  //   if (onDelete != null) onDelete();

  //   if (id != null) {
  //     LemburService.deleteLembur(id).then((_) async {
  //       await fetchLembur(forceRefresh: true);
  //       if (filteredLemburList.isNotEmpty) filterLembur('');
  //     });
  //   }
  // }
}

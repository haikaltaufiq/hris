import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hr/data/models/cuti_model.dart';
import 'package:hr/data/services/cuti_service.dart';

class CutiProvider with ChangeNotifier {
  List<CutiModel> _cutiList = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CutiModel> get cutiList => _cutiList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<CutiModel> filteredCutiList = [];
  final String _currentSearch = '';

  final _cutiBox = Hive.box('cuti');
  bool _hasCache = false;
  bool get hasCache => _hasCache;

  /// Load cache immediately (synchronous)
  void loadCacheFirst() {
    try {
      final hasCache = _cutiBox.containsKey('cuti_list');
      if (hasCache) {
        final cached = _cutiBox.get('cuti_list') as List;
        if (cached.isNotEmpty) {
          _cutiList = cached
              .map(
                  (json) => CutiModel.fromJson(Map<String, dynamic>.from(json)))
              .toList();
          _hasCache = true;
          notifyListeners(); // Update UI immediately
          print('✅ Cache loaded: ${_cutiList.length} items');
        }
      }
    } catch (e) {
      print('❌ Error loading cache: $e');
    }
  }

  /// Ambil semua data cuti dari API
  Future<void> fetchCuti({bool forceRefresh = false}) async {
    print('🔄 fetchCuti called - forceRefresh: $forceRefresh');

    // Load cache first if not force refresh
    if (!forceRefresh && _cutiList.isEmpty) {
      loadCacheFirst();
    }

    _isLoading = true;
    notifyListeners();

    try {
      print('🌐 Calling API...');
      final apiData = await CutiService.fetchCuti();
      print('✅ API success: ${apiData.length} items');

      _cutiList = apiData;
      filteredCutiList.clear();
      _errorMessage = null;

      // Save to cache
      await _cutiBox.put(
        'cuti_list',
        _cutiList.map((c) => c.toJson()).toList(),
      );
      print('💾 Cache saved');

      _hasCache = true;
    } catch (e) {
      print('❌ API Error: $e');
      _errorMessage = e.toString();

      // If no data and cache exists, load cache
      if (_cutiList.isEmpty) {
        loadCacheFirst();
      }
    }

    _isLoading = false;
    notifyListeners();
    print('🏁 fetchCuti completed - items: ${_cutiList.length}');
  }

  /// Searching fitur
  void filterCuti(String query) {
    if (query.isEmpty) {
      filteredCutiList.clear();
    } else {
      final lowerQuery = query.toLowerCase();
      filteredCutiList = cutiList.where((cuti) {
        final namaKaryawan = (cuti.user['nama'] ?? '').toString().toLowerCase();
        return namaKaryawan.contains(lowerQuery) ||
            cuti.alasan.toLowerCase().contains(lowerQuery) ||
            cuti.tipe_cuti.toLowerCase().contains(lowerQuery) ||
            cuti.status.toLowerCase().contains(lowerQuery) ||
            cuti.tanggal_mulai.toLowerCase().contains(lowerQuery) ||
            cuti.tanggal_selesai.toLowerCase().contains(lowerQuery);
      }).toList();
    }
    notifyListeners();
  }

  /// Tambah cuti baru
  Future<bool> createCuti({
    required String nama,
    required String tipeCuti,
    required String tanggalMulai,
    required String tanggalSelesai,
    required String alasan,
  }) async {
    final success = await CutiService.createCuti(
      nama: nama,
      tipeCuti: tipeCuti,
      tanggalMulai: tanggalMulai,
      tanggalSelesai: tanggalSelesai,
      alasan: alasan,
    );

    if (success) {
      await fetchCuti(forceRefresh: true); // refresh data
    }

    return success;
  }

  /// Edit cuti
  Future<Map<String, dynamic>> editCuti({
    required int id,
    required String nama,
    required String tipeCuti,
    required String tanggalMulai,
    required String tanggalSelesai,
    required String alasan,
  }) async {
    final result = await CutiService.editCuti(
      id: id,
      nama: nama,
      tipeCuti: tipeCuti,
      tanggalMulai: tanggalMulai,
      tanggalSelesai: tanggalSelesai,
      alasan: alasan,
    );

    if (result['success'] == true) {
      await fetchCuti(forceRefresh: true); // refresh data
    }

    return result;
  }

  /// Hapus cuti
  Future<String> deleteCuti(int id, String currentSearch) async {
    final result = await CutiService.deleteCuti(id);
    await fetchCuti(forceRefresh: true);
    filterCuti(_currentSearch);
    return result['message'] ?? 'Tidak ada pesan';
  }

  /// Approve cuti
  Future<String?> approveCuti(int id, String currentSearch) async {
    final message = await CutiService.approveCuti(id);
    await fetchCuti(forceRefresh: true);
    filterCuti(_currentSearch);
    return message;
  }

  /// Decline cuti
  Future<String?> declineCuti(int id, String currentSearch) async {
    final message = await CutiService.declineCuti(id);
    await fetchCuti(forceRefresh: true);
    filterCuti(_currentSearch);

    return message;
  }

  /// Approve cuti (tetap bisa pakai onApprove callback)
  Future<void> approve(Future<void> Function()? onApprove, {int? id}) async {
    if (onApprove != null) await onApprove(); // panggil callback UI dulu

    if (id != null) {
      await CutiService.approveCuti(id); // update di backend
      await fetchCuti(forceRefresh: true); // refresh cuti utama
      // apply filter lagi jika ada search aktif
      if (filteredCutiList.isNotEmpty) filterCuti('');
    }
  }

  /// Decline cuti (tetap bisa pakai onDecline callback)
  Future<void> decline(Future<void> Function()? onDecline, {int? id}) async {
    if (onDecline != null) await onDecline();

    if (id != null) {
      await CutiService.declineCuti(id);
      await fetchCuti(forceRefresh: true);
      if (filteredCutiList.isNotEmpty) filterCuti('');
    }
  }

  /// Delete cuti (tetap bisa pakai onDelete callback)
  void delete(VoidCallback? onDelete, {int? id}) {
    if (onDelete != null) onDelete();

    if (id != null) {
      CutiService.deleteCuti(id).then((_) async {
        await fetchCuti(forceRefresh: true);
        if (filteredCutiList.isNotEmpty) filterCuti('');
      });
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hr/data/models/absen_model.dart';
import 'package:hr/data/services/absen_service.dart';

class AbsenProvider extends ChangeNotifier {
  // ================= STATE ================= //
  List<AbsenModel> _absensi = [];
  List<AbsenModel> _filteredAbsensi = [];
  String _currentSearch = '';

  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? _lastCheckinResult;
  Map<String, dynamic>? _lastCheckoutResult;

  // ================= GETTER ================= //
  List<AbsenModel> get absensi => _absensi;
  List<AbsenModel> get filteredAbsensi => _filteredAbsensi;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Map<String, dynamic>? get lastCheckinResult => _lastCheckinResult;
  Map<String, dynamic>? get lastCheckoutResult => _lastCheckoutResult;

  final _absenBox = Hive.box('absen');
  bool _hasCache = false;
  bool get hasCache => _hasCache;

  bool _hasCheckedInToday = false;

  bool get hasCheckedInToday => _hasCheckedInToday;

  int get jumlahHadir => _absensi.map((a) => a.userId).toSet().length;

  double attendanceRate(int totalUsers) {
    if (totalUsers == 0) return 0;
    return (jumlahHadir / totalUsers) * 100;
  }

  // ================= SERVICE WRAPPER ================= //
  /// Load cache immediately (synchronous)
  void loadCacheFirst() {
    try {
      final hasCache = _absenBox.containsKey('absen_list');
      if (hasCache) {
        final cached = _absenBox.get('absen_list') as List;
        if (cached.isNotEmpty) {
          _absensi = cached
              .map((json) =>
                  AbsenModel.fromJson(Map<String, dynamic>.from(json)))
              .toList();
          _hasCache = true;
          notifyListeners(); // Update UI immediately
          if (kDebugMode) {
            print('✅ Cache loaded: ${_absensi.length} items');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading cache: $e');
      }
    }
  }

  /// Fetch daftar absensi
  Future<void> fetchAbsensi({bool forceRefresh = false}) async {
    if (kDebugMode) {
      print('🔄 fetchAbsen called - forceRefresh: $forceRefresh');
    }

    // Load cache first if not force refresh
    if (!forceRefresh && _absensi.isEmpty) {
      loadCacheFirst();
    }

    _isLoading = true;
    notifyListeners();

    try {
      if (kDebugMode) {
        print('🌐 Calling API...');
      }
      final apiData = await AbsenService.fetchAbsensi();
      if (kDebugMode) {
        print('✅ API success: ${apiData.length} items');
      }

      _absensi = apiData;
      filteredAbsensi.clear();
      _errorMessage = null;

      //   cek absen hari ini
      final today = DateTime.now();
      final todayStr = "${today.year.toString().padLeft(4, '0')}-"
          "${today.month.toString().padLeft(2, '0')}-"
          "${today.day.toString().padLeft(2, '0')}";
      _hasCheckedInToday = _absensi.any((a) => a.checkinDate == todayStr);

      // Save to cache
      await _absenBox.put(
        'absen_list',
        _absensi.map((c) => c.toJson()).toList(),
      );
      if (kDebugMode) {
        print('💾 Cache saved');
      }

      _hasCache = true;
    } catch (e) {
      print('❌ API Error: $e');
      _errorMessage = e.toString();

      // If no data and cache exists, load cache
      if (_absensi.isEmpty) {
        loadCacheFirst();
      }
    }

    _isLoading = false;
    notifyListeners();
    print('🏁 fetchAbsensi completed - items: ${_absensi.length}');
  }

  /// Check-in
  Future<void> checkin({
    required double lat,
    required double lng,
    required String checkinDate,
    required String checkinTime,
    required String videoPath,
    Uint8List? videoBytes,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final result = await AbsenService.checkin(
        lat: lat,
        lng: lng,
        checkinDate: checkinDate,
        checkinTime: checkinTime,
        videoPath: videoPath,
        videoBytes: videoBytes,
      );
      _lastCheckinResult = result;
    } catch (e) {
      _setError('Gagal check-in: $e');
    }
    _setLoading(false);
  }

  /// Check-out
  Future<void> checkout({
    required double lat,
    required double lng,
    required String checkoutDate,
    required String checkoutTime,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final result = await AbsenService.checkout(
        lat: lat,
        lng: lng,
        checkoutDate: checkoutDate,
        checkoutTime: checkoutTime,
      );
      _lastCheckoutResult = result;
    } catch (e) {
      _setError('Gagal check-out: $e');
    }
    _setLoading(false);
  }

  // ================= SEARCH ================= //
  void searchAbsensi(String query) {
    _currentSearch = query.trim().toLowerCase();

    if (_currentSearch.isEmpty) {
      _filteredAbsensi = [];
    } else {
      _filteredAbsensi = _absensi.where((absen) {
        final fields = [
          absen.id?.toString(),
          absen.userId?.toString(),
          absen.tugasId?.toString(),
          absen.checkinLat?.toString(),
          absen.checkinLng?.toString(),
          absen.checkinTime,
          absen.checkinDate,
          absen.checkoutLat?.toString(),
          absen.checkoutLng?.toString(),
          absen.checkoutTime,
          absen.checkoutDate,
          absen.videoUser,
          absen.status,
          absen.createdAt,
          absen.updatedAt,
          // nested user
          absen.user?.nama,
          absen.user?.email,
          absen.user?.jenisKelamin,
          absen.user?.statusPernikahan,
          absen.user?.jabatan?.namaJabatan,
          absen.user?.peran.namaPeran,
          absen.user?.departemen.namaDepartemen,
          absen.user?.gajiPokok,
          absen.user?.npwp,
          absen.user?.bpjsKesehatan,
          absen.user?.bpjsKetenagakerjaan,
        ];

        return fields
            .whereType<String>() // buang null
            .map((f) => f.toLowerCase())
            .any((f) => f.contains(_currentSearch));
      }).toList();
    }

    notifyListeners();
  }

  // ================= PRIVATE HELPER ================= //
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  List<AbsenModel> get todayAbsensi {
    final today = DateTime.now();
    final todayStr = "${today.year.toString().padLeft(4, '0')}-"
        "${today.month.toString().padLeft(2, '0')}-"
        "${today.day.toString().padLeft(2, '0')}";

    return _absensi.where((a) => a.checkinDate == todayStr).toList();
  }

  /// Jumlah karyawan yang absen hari ini
  int get todayJumlahHadir => todayAbsensi.length;

  /// Jumlah poin kehadiran hari ini (misal "Hadir" = 1, "Terlambat" = 0.5)
  double get todayAttendancePoints {
    double total = 0;
    for (var absen in todayAbsensi) {
      if (absen.status == 'Hadir') total += 1;
      if (absen.status == 'Terlambat') total += 0.5;
    }
    return total;
  }
}

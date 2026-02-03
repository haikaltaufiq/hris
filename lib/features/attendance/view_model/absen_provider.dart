import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hr/core/helpers/feature_guard.dart';
import 'package:hr/data/models/absen_model.dart';
import 'package:hr/data/services/absen_service.dart';

/// AbsenProvider
/// ---------------------------------------------------------------------------
/// Responsibilities:
/// - Fetch attendance data from API
/// - Cache attendance data locally using Hive
/// - Provide sorting, searching, and filtering utilities
/// - Expose attendance analytics (daily, monthly, rate)
/// - Handle check-in and check-out actions
/// ---------------------------------------------------------------------------
class AbsenProvider extends ChangeNotifier {
  // ===========================================================================
  // STATE
  // ===========================================================================

  /// Master raw data from API / cache
  List<AbsenModel> _allAbsensi = [];

  /// Active data after sort/filter (main list)
  List<AbsenModel> _absensi = [];

  /// Search or month-filtered result
  List<AbsenModel> _filteredAbsensi = [];

  /// UI state
  bool _isLoading = false;
  String? _errorMessage;

  /// Search & sort state
  String _currentSearch = '';
  String _currentSortField = 'hari';

  /// Attendance state
  bool _hasCheckedInToday = false;

  /// API result tracking
  Map<String, dynamic>? _lastCheckinResult;
  Map<String, dynamic>? _lastCheckoutResult;

  /// Cache
  final Box _absenBox = Hive.box('absen');
  bool _hasCache = false;

  // ===========================================================================
  // GETTERS (PUBLIC API)
  // ===========================================================================

  List<AbsenModel> get absensi => _absensi;
  List<AbsenModel> get allAbsensi => _allAbsensi;
  List<AbsenModel> get filteredAbsensi => _filteredAbsensi;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get hasCache => _hasCache;
  bool get hasCheckedInToday => _hasCheckedInToday;

  String get currentSortField => _currentSortField;

  Map<String, dynamic>? get lastCheckinResult => _lastCheckinResult;
  Map<String, dynamic>? get lastCheckoutResult => _lastCheckoutResult;

  /// Unique users present in current dataset
  int get jumlahHadir => _absensi.map((a) => a.userId).toSet().length;

  /// Attendance rate in percentage
  double attendanceRate(int totalUsers) {
    if (totalUsers == 0) return 0;
    return (jumlahHadir / totalUsers) * 100;
  }

  // ===========================================================================
  // CACHE
  // ===========================================================================

  /// Load cached attendance data synchronously
  void loadCacheFirst() {
    try {
      if (!_absenBox.containsKey('absen_list')) return;

      final cached = _absenBox.get('absen_list') as List;
      if (cached.isEmpty) return;

      _allAbsensi = cached
          .map(
            (json) => AbsenModel.fromJson(Map<String, dynamic>.from(json)),
          )
          .toList();

      _absensi = List.from(_allAbsensi);
      _hasCache = true;

      notifyListeners();
    } catch (_) {
      // Silent fail: cache is optional
    }
  }

  // ===========================================================================
  // FETCH
  // ===========================================================================

  /// Fetch attendance data from API
  Future<void> fetchAbsensi({bool forceRefresh = false}) async {
    final userBox = await Hive.openBox('user');
    final currentUserId = userBox.get('id');
    final canViewAll = FeatureAccess.has('lihat_semua_absensi');

    if (!forceRefresh && _absensi.isEmpty) {
      loadCacheFirst();
    }

    _setLoading(true);

    try {
      final apiData = await AbsenService.fetchAbsensi();

      _allAbsensi = apiData;

      /// Default sort behavior based on permission
      sortAbsensi(canViewAll ? 'hari' : 'terbaru');

      _filteredAbsensi.clear();
      _errorMessage = null;

      _hasCheckedInToday = _allAbsensi.any(
        (a) => a.userId == currentUserId && a.checkinDate == _todayString,
      );

      await _absenBox.put(
        'absen_list',
        _allAbsensi.map((e) => e.toJson()).toList(),
      );

      _hasCache = true;
    } catch (e) {
      _errorMessage = e.toString();

      if (_absensi.isEmpty) {
        loadCacheFirst();
      }
    }

    _setLoading(false);
  }

  // ===========================================================================
  // CHECK-IN / CHECK-OUT
  // ===========================================================================

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
      _lastCheckinResult = await AbsenService.checkin(
        lat: lat,
        lng: lng,
        checkinDate: checkinDate,
        checkinTime: checkinTime,
        videoPath: videoPath,
        videoBytes: videoBytes,
      );
    } catch (e) {
      _setError('Check-in failed: $e');
    }

    _setLoading(false);
  }

  Future<void> checkout({
    required double lat,
    required double lng,
    required String checkoutDate,
    required String checkoutTime,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _lastCheckoutResult = await AbsenService.checkout(
        lat: lat,
        lng: lng,
        checkoutDate: checkoutDate,
        checkoutTime: checkoutTime,
      );
    } catch (e) {
      _setError('Check-out failed: $e');
    }

    _setLoading(false);
  }

  // ===========================================================================
  // SEARCH & FILTER
  // ===========================================================================

  void searchAbsensi(String query) {
    _currentSearch = query.trim().toLowerCase();

    if (_currentSearch.isEmpty) {
      _filteredAbsensi.clear();
      notifyListeners();
      return;
    }

    _filteredAbsensi = _absensi.where((absen) {
      final fields = <String?>[
        absen.id?.toString(),
        absen.userId?.toString(),
        absen.tugasId?.toString(),
        absen.checkinDate,
        absen.checkinTime,
        absen.checkoutDate,
        absen.checkoutTime,
        absen.status,
        absen.user?.nama,
        absen.user?.email,
        absen.user?.jabatan?.namaJabatan,
        absen.user?.peran?.namaPeran,
        absen.user?.departemen?.namaDepartemen,
      ];

      return fields
          .whereType<String>()
          .any((f) => f.toLowerCase().contains(_currentSearch));
    }).toList();

    notifyListeners();
  }

  void filterByMonth(int month, int year) {
    _filteredAbsensi = _allAbsensi.where((absen) {
      if (absen.checkinDate == null) return false;
      try {
        final date = DateTime.parse(absen.checkinDate!);
        return date.month == month && date.year == year;
      } catch (_) {
        return false;
      }
    }).toList();

    notifyListeners();
  }

  // ===========================================================================
  // SORT
  // ===========================================================================

  void sortAbsensi(String field) {
    _currentSortField = field;

    final List<AbsenModel> source = List.from(_allAbsensi);

    switch (field) {
      case 'hari':
        _absensi = source.where((a) => a.checkinDate == _todayString).toList();
        break;

      case 'semua':
        _absensi = source;
        break;

      case 'terbaru':
        source.sort(_compareDateDesc);
        _absensi = source;
        break;

      case 'terlama':
        source.sort(_compareDateAsc);
        _absensi = source;
        break;

      case 'nama':
        source.sort(
          (a, b) => (a.user?.nama ?? '').compareTo(b.user?.nama ?? ''),
        );
        _absensi = source;
        break;

      default:
        _absensi = source;
    }

    if (_currentSearch.isNotEmpty) {
      searchAbsensi(_currentSearch);
    } else {
      notifyListeners();
    }
  }

  // ===========================================================================
  // ANALYTICS
  // ===========================================================================

  List<AbsenModel> get todayAbsensi =>
      _allAbsensi.where((a) => a.checkinDate == _todayString).toList();

  int get todayJumlahHadir => todayAbsensi.length;

  double get todayAttendancePoints {
    double total = 0;
    for (final absen in todayAbsensi) {
      if (absen.status == 'Hadir') total += 1;
      if (absen.status == 'Terlambat') total += 0.5;
    }
    return total;
  }

  /// Monthly attendance count (index 0 = January)
  List<double> get monthlyAttendance {
    final List<double> result = List.filled(12, 0);

    for (final absen in _allAbsensi) {
      if (absen.checkinDate == null) continue;

      try {
        final date = DateTime.parse(absen.checkinDate!);
        result[date.month - 1] += absen.isHadir ? 1 : 0;
      } catch (_) {}
    }

    return result;
  }

  int get countAbsensiHariIni => todayAbsensi.length;

  // ===========================================================================
  // PRIVATE HELPERS
  // ===========================================================================

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

  String get _todayString {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  int _compareDateDesc(AbsenModel a, AbsenModel b) {
    final da = DateTime.tryParse(a.checkinDate ?? '');
    final db = DateTime.tryParse(b.checkinDate ?? '');
    if (da == null || db == null) return 0;
    return db.compareTo(da);
  }

  int _compareDateAsc(AbsenModel a, AbsenModel b) {
    final da = DateTime.tryParse(a.checkinDate ?? '');
    final db = DateTime.tryParse(b.checkinDate ?? '');
    if (da == null || db == null) return 0;
    return da.compareTo(db);
  }
}

/// AbsenModel extension
extension AbsenModelExt on AbsenModel {
  bool get isHadir => status != null && status!.toLowerCase() == 'hadir';
}

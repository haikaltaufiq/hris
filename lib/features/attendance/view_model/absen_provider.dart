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

enum AbsenSortType {
  day,
  week,
  month,
  year,
  name,
  terbaru,
  terlama,
}

class AbsenAdvancedFilter {
  final String search;
  final DateTime? day;
  final int? week;
  final int? month;
  final int? year;
  final AbsenSortType sort;

  const AbsenAdvancedFilter({
    this.search = '',
    this.day,
    this.week,
    this.month,
    this.year,
    this.sort = AbsenSortType.day,
  });
}

class AbsenProvider extends ChangeNotifier {
  // ===========================================================================
  // STATE
  // ===========================================================================

  List<AbsenModel> _allAbsensi = [];
  List<AbsenModel> _absensi = [];
  List<AbsenModel> _filteredAbsensi = [];

  bool _isLoading = false;
  String? _errorMessage;

  String _currentSearch = '';
  String _currentSortField = 'hari';

  bool _hasCheckedInToday = false;

  Map<String, dynamic>? _lastCheckinResult;
  Map<String, dynamic>? _lastCheckoutResult;

  final Box _absenBox = Hive.box('absen');
  bool _hasCache = false;

  List<AbsenModel> _advancedAbsensi = [];

  // ===========================================================================
  // GETTERS (PUBLIC API)
  // ===========================================================================

  List<AbsenModel> get absensi => _absensi;
  List<AbsenModel> get allAbsensi => _allAbsensi;
  List<AbsenModel> get filteredAbsensi => _filteredAbsensi;
  List<AbsenModel> get advancedAbsensi => _advancedAbsensi;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get hasCache => _hasCache;
  bool get hasCheckedInToday => _hasCheckedInToday;

  String get currentSortField => _currentSortField;

  Map<String, dynamic>? get lastCheckinResult => _lastCheckinResult;
  Map<String, dynamic>? get lastCheckoutResult => _lastCheckoutResult;

  int get jumlahHadir => _absensi.map((a) => a.userId).toSet().length;

  double attendanceRate(int totalUsers) {
    if (totalUsers == 0) return 0;
    return (jumlahHadir / totalUsers) * 100;
  }

  // ===========================================================================
  // CACHE
  // ===========================================================================

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
  // SEARCH & FILTER (LEGACY)
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
  // SORT (LEGACY)
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
  // ADVANCED FILTER & SORT (FOR AbsenWeb)
  // ===========================================================================

  void applyAdvancedFilter(AbsenAdvancedFilter filter) {
    Iterable<AbsenModel> result = _allAbsensi;

    // Apply month and year filter first (primary filter)
    if (filter.month != null && filter.year != null) {
      result = result.where((a) {
        final d = DateTime.tryParse(a.checkinDate ?? '');
        return d != null && d.month == filter.month && d.year == filter.year;
      });
    } else if (filter.year != null) {
      // Year only filter
      result = result.where((a) {
        final d = DateTime.tryParse(a.checkinDate ?? '');
        return d != null && d.year == filter.year;
      });
    }

    // Apply day filter (override month/year if specified)
    if (filter.day != null) {
      final target = _dateOnly(filter.day!);
      result = result.where((a) {
        final d = DateTime.tryParse(a.checkinDate ?? '');
        return d != null && _dateOnly(d) == target;
      });
    }

    // Apply week filter (within year)
    if (filter.week != null && filter.year != null) {
      result = result.where((a) {
        final d = DateTime.tryParse(a.checkinDate ?? '');
        if (d == null) return false;
        return _weekOfYear(d) == filter.week && d.year == filter.year;
      });
    }

    // Apply search filter
    if (filter.search.isNotEmpty) {
      final q = filter.search.toLowerCase();
      result = result.where((a) {
        final fields = <String?>[
          a.user?.nama,
          a.user?.email,
          a.status,
          a.checkinDate,
          a.checkoutDate,
          a.checkinTime,
          a.checkoutTime,
          a.user?.jabatan?.namaJabatan,
          a.user?.departemen?.namaDepartemen,
        ];
        return fields
            .whereType<String>()
            .any((f) => f.toLowerCase().contains(q));
      });
    }

    final list = result.toList();

    // Apply sorting
    switch (filter.sort) {
      case AbsenSortType.name:
        list.sort(
          (a, b) => (a.user?.nama ?? '').compareTo(b.user?.nama ?? ''),
        );
        break;

      case AbsenSortType.terbaru:
        list.sort(_compareDateDesc);
        break;

      case AbsenSortType.terlama:
        list.sort(_compareDateAsc);
        break;

      case AbsenSortType.week:
        list.sort((a, b) {
          final da = DateTime.tryParse(a.checkinDate ?? '');
          final db = DateTime.tryParse(b.checkinDate ?? '');
          if (da == null || db == null) return 0;
          final weekCompare = _weekOfYear(db).compareTo(_weekOfYear(da));
          if (weekCompare != 0) return weekCompare;
          return db.compareTo(da);
        });
        break;

      case AbsenSortType.day:
        list.sort(_compareDateDesc);
        break;

      case AbsenSortType.month:
        list.sort((a, b) {
          final da = DateTime.tryParse(a.checkinDate ?? '');
          final db = DateTime.tryParse(b.checkinDate ?? '');
          if (da == null || db == null) return 0;
          final monthCompare = db.month.compareTo(da.month);
          if (monthCompare != 0) return monthCompare;
          return db.compareTo(da);
        });
        break;

      case AbsenSortType.year:
        list.sort((a, b) {
          final da = DateTime.tryParse(a.checkinDate ?? '');
          final db = DateTime.tryParse(b.checkinDate ?? '');
          if (da == null || db == null) return 0;
          return db.year.compareTo(da.year);
        });
        break;
    }

    _advancedAbsensi = list;
    notifyListeners();
  }

  // ===========================================================================
  // PRIVATE HELPERS
  // ===========================================================================

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  int _weekOfYear(DateTime date) {
    final firstDay = DateTime(date.year, 1, 1);
    final diff = date.difference(firstDay).inDays;
    return ((diff + firstDay.weekday) / 7).ceil();
  }

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

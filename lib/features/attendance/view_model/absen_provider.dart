import 'package:flutter/foundation.dart';
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

  // ================= SERVICE WRAPPER ================= //

  /// Fetch daftar absensi
  Future<void> fetchAbsensi() async {
    _setLoading(true);
    _clearError();
    try {
      final result = await AbsenService.fetchAbsensi();
      _absensi = result;
      _filteredAbsensi = [];
    } catch (e) {
      _setError('Gagal ambil data absensi: $e');
    }
    _setLoading(false);
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
}

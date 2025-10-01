import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hr/data/models/tugas_model.dart';
import 'package:hr/data/services/tugas_service.dart';

class TugasProvider extends ChangeNotifier {
  List<TugasModel> _tugasList = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TugasModel> get tugasList => _tugasList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<TugasModel> filteredTugasList = [];
  final String _currentSearch = '';
  final _tugasBox = Hive.box('tugas');
  bool _hasCache = false;
  bool get hasCache => _hasCache;
  int get totalAllTugas => _tugasList.length;

  int get totalTugas => _tugasList
      .where((tugas) => tugas.status.toLowerCase() != 'selesai')
      .length;

  int get totalTugasSelesai => _tugasList
      .where((tugas) => tugas.status.toLowerCase() == 'selesai')
      .length;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Load cache immediately (synchronous)
  void loadCacheFirst() {
    try {
      final hasCache = _tugasBox.containsKey('tugas_list');
      if (hasCache) {
        final cached = _tugasBox.get('tugas_list') as List;
        if (cached.isNotEmpty) {
          _tugasList = cached
              .map((json) =>
                  TugasModel.fromJson(Map<String, dynamic>.from(json)))
              .toList();
          _hasCache = true;
          notifyListeners(); // Update UI immediately
          print('✅ Cache loaded: ${_tugasList.length} items');
        }
      }
    } catch (e) {
      print('❌ Error loading cache: $e');
    }
  }

  // Fetch data tugas
// Fetch semua tugas
  Future<void> fetchTugas({bool forceRefresh = false}) async {
    print('🔄 fetchTugas called - forceRefresh: $forceRefresh');

    // Load cache first if not force refresh
    if (!forceRefresh && _tugasList.isEmpty) {
      loadCacheFirst();
    }

    _isLoading = true;
    notifyListeners();

    try {
      print('🌐 Calling API...');
      final apiData = await TugasService.fetchTugas();
      print('✅ API success: ${apiData.length} items');

      _tugasList = apiData;
      filteredTugasList.clear();
      _errorMessage = null;

      // Save to cache
      await _tugasBox.put(
        'tugas_list',
        _tugasList.map((c) => c.toJson()).toList(),
      );
      print('💾 Cache saved');

      _hasCache = true;
    } catch (e) {
      print('❌ API Error: $e');
      _errorMessage = e.toString();

      // If no data and cache exists, load cache
      if (_tugasList.isEmpty) {
        loadCacheFirst();
      }
    }

    _isLoading = false;
    notifyListeners();
    print('🏁 fetchLembur completed - items: ${_tugasList.length}');
  }

  /// Searching fitur untuk Tugas
  void filterTugas(String query) {
    if (query.isEmpty) {
      filteredTugasList.clear();
    } else {
      final lowerQuery = query.toLowerCase();
      filteredTugasList = _tugasList.where((tugas) {
        final namaKaryawan = (tugas.user?.nama ?? '').toLowerCase();
        return (tugas.namaTugas.toLowerCase().contains(lowerQuery)) ||
            namaKaryawan.contains(lowerQuery) ||
            (tugas.lokasi.toLowerCase().contains(lowerQuery)) ||
            (tugas.note.toLowerCase().contains(lowerQuery)) ||
            (tugas.status.toLowerCase().contains(lowerQuery)) ||
            (tugas.tanggalMulai.toLowerCase().contains(lowerQuery)) ||
            (tugas.tanggalSelesai.toLowerCase().contains(lowerQuery)) ||
            (tugas.jamMulai.toLowerCase().contains(lowerQuery));
      }).toList();
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> createTugas({
    required String judul,
    required String jamMulai,
    required String tanggalMulai,
    required String tanggalSelesai,
    int? person,
    required String lokasi,
    required String note,
  }) async {
    _setLoading(true);
    try {
      final result = await TugasService.createTugas(
        judul: judul,
        jamMulai: jamMulai,
        tanggalMulai: tanggalMulai,
        tanggalSelesai: tanggalSelesai,
        person: person,
        lokasi: lokasi,
        note: note,
      );
      _isLoading = false;
      if (result['success'] == true) {
        await fetchTugas(forceRefresh: true);
      }
      return result;
    } catch (e) {
      debugPrint("Error create tugas: $e");
      return {'success': false, 'message': 'Terjadi Kegagalan'};
    } finally {
      _setLoading(false);
    }
  }

  // Update tugas
  Future<Map<String, dynamic>> updateTugas({
    required int id,
    required String judul,
    required String jamMulai,
    required String tanggalMulai,
    required String tanggalSelesai,
    int? person,
    int? departmentId,
    required String lokasi,
    required String note,
  }) async {
    _setLoading(true);
    try {
      final result = await TugasService.updateTugas(
        id: id,
        judul: judul,
        jamMulai: jamMulai,
        tanggalMulai: tanggalMulai,
        tanggalSelesai: tanggalSelesai,
        person: person,
        lokasi: lokasi,
        note: note,
      );
      if (result['success'] == true) {
        await fetchTugas(forceRefresh: true);
      }
      return result;
    } catch (e) {
      debugPrint("Error update tugas: $e");
      return {'success': false, 'message': 'Terjadi kesalahan'};
    } finally {
      _setLoading(false);
    }
  }

  // Hapus tugas
  Future<String?> deleteTugas(int id, String currentSearch) async {
    _setLoading(true);
    try {
      final result = await TugasService.deleteTugas(id);
      await fetchTugas(forceRefresh: true);
      filterTugas(_currentSearch);
      return result['message'];
    } catch (e) {
      debugPrint("Error delete tugas: $e");
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> updateTugasStatus(int id, String status) async {
    try {
      final result = await TugasService.updateStatus(id: id, status: status);
      if (result['success'] == true) {
        await fetchTugas(forceRefresh: true);
        return result['message'];
      } else {
        return result['message'];
      }
    } catch (e) {
      return "Terjadi error: $e";
    }
  }

  int get todayActiveTask {
    final today = DateTime.now();

    return _tugasList.where((tugas) {
      try {
        final selesai = DateTime.parse(tugas.tanggalSelesai);
        // bandingkan hanya tanggal, abaikan jam
        return selesai.year == today.year &&
            selesai.month == today.month &&
            selesai.day == today.day;
      } catch (e) {
        return false;
      }
    }).length;
  }

  /// Menghitung jumlah tugas per bulan berdasarkan status
  Map<String, List<double>> getMonthlyData() {
    // Inisialisasi 12 bulan (index 0 = Jan, 11 = Dec)
    List<double> target = List.filled(12, 0);
    List<double> attendanceRate = List.filled(12, 0);
    List<double> projectCompletion = List.filled(12, 0);

    for (final tugas in _tugasList) {
      try {
        DateTime? date = DateTime.tryParse(tugas.tanggalMulai);
        if (date == null) continue;

        int monthIndex = date.month - 1;

        // Semua tugas dihitung sebagai target
        target[monthIndex] += 1;

        // Status selesai = projectCompletion
        if (tugas.status.toLowerCase() == 'selesai') {
          projectCompletion[monthIndex] += 1;
        }

        // Status lain dianggap menunggu/admin = attendanceRate
        else {
          attendanceRate[monthIndex] += 1;
        }
      } catch (e) {
        print('Error parsing tugas tanggalMulai: $e');
      }
    }

    return {
      'target': target,
      'attendanceRate': attendanceRate,
      'projectCompletion': projectCompletion,
    };
  }
}

// ignore_for_file: curly_braces_in_flow_control_structures, avoid_print, prefer_interpolation_to_compose_strings

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

  String _currentSortField = 'terbaru';
  String get currentSortField => _currentSortField;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

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
          notifyListeners();
          // print(' Cache loaded: ${_tugasList.length} items');
        }
      }
    } catch (e) {
      // print(' Error loading cache: $e');
    }
  }

  Future<void> fetchTugas({bool forceRefresh = false}) async {
    if (!forceRefresh && _tugasList.isEmpty) loadCacheFirst();
    _setLoading(true);
    try {
      final apiData = await TugasService.fetchTugas();

      tugasList.clear();
      _tugasList = apiData;
      sortTugas('terbaru');

      filteredTugasList.clear();
      _errorMessage = null;

      await _tugasBox.put(
        'tugas_list',
        _tugasList.map((c) => c.toJson()).toList(),
      );
      _hasCache = true;
    } catch (e) {
      _errorMessage = e.toString();
      if (_tugasList.isEmpty) loadCacheFirst();
    }
    _setLoading(false);
  }

  void sortTugas(String order) {
    if (_tugasList.isEmpty) return;
    _currentSortField = order;

    switch (order) {
      case 'terlama':
        _tugasList.sort((a, b) => DateTime.parse(a.tanggalPenugasan)
            .compareTo(DateTime.parse(b.tanggalPenugasan)));
        break;
      case 'terbaru':
        _tugasList.sort((a, b) => DateTime.parse(b.tanggalPenugasan)
            .compareTo(DateTime.parse(a.tanggalPenugasan)));
        break;
      case 'nama':
        _tugasList.sort((a, b) => a.displayUser.compareTo(b.displayUser));
        break;
      case 'status':
        _tugasList.sort((a, b) => a.status.compareTo(b.status));
        break;
    }

    notifyListeners();
  }

  void filterTugas(String query) {
    if (query.isEmpty) {
      filteredTugasList.clear();
    } else {
      final lowerQuery = query.toLowerCase();
      filteredTugasList = _tugasList.where((tugas) {
        final namaTugas = tugas.namaTugas.toLowerCase();
        final status = tugas.status.toLowerCase();
        final tanggalPenugasan = tugas.tanggalPenugasan.toLowerCase();
        final batasPenugasan = tugas.batasPenugasan.toLowerCase();
        final note = tugas.note?.toLowerCase() ?? '';
        final namaKaryawan = tugas.user?.nama.toLowerCase() ?? '';

        return namaTugas.contains(lowerQuery) ||
            namaKaryawan.contains(lowerQuery) ||
            note.contains(lowerQuery) ||
            status.contains(lowerQuery) ||
            tanggalPenugasan.contains(lowerQuery) ||
            batasPenugasan.contains(lowerQuery);
      }).toList();
    }
    notifyListeners();
  }

  // Create tugas dengan koordinat
  Future<Map<String, dynamic>> createTugas({
    required String judul,
    required String tugaslok,
    required String tanggalPenugasan,
    required String batasPenugasan,
    // required double tugasLat,
    // required double tugasLng,
    int? person,
    double? lampiranLat,
    double? lampiranLng,
    required String note,
    // required int radius, // Tambah ini
  }) async {
    _setLoading(true);
    try {
      final result = await TugasService.createTugas(
        judul: judul,
        tanggalPenugasan: tanggalPenugasan,
        batasPenugasan: batasPenugasan,
        tugaslok: tugaslok,
        // tugasLat: tugasLat,
        // tugasLng: tugasLng,
        person: person,
        lampiranLat: lampiranLat,
        lampiranLng: lampiranLng,
        note: note,
        // radius: radius.toString(),
      );
      if (result['success'] == true) await fetchTugas(forceRefresh: true);
      return result;
    } catch (e) {
      // debugPrint("Error create tugas: $e");
      return {'success': false, 'message': 'Terjadi Kegagalan'};
    } finally {
      _setLoading(false);
    }
  }

  // Update tugas dengan koordinat
  Future<Map<String, dynamic>> updateTugas({
    required int id,
    required String judul,
    required String tugaslok,
    required String tanggalPenugasan,
    required String batasPenugasan,
    // required double tugasLat,
    // required double tugasLng,
    int? person,
    double? lampiranLat,
    double? lampiranLng,
    required String note,
    // required int radius, // Tambah ini
  }) async {
    _setLoading(true);
    try {
      final result = await TugasService.updateTugas(
        id: id,
        judul: judul,
        tugaslok: tugaslok,
        tanggalPenugasan: tanggalPenugasan,
        batasPenugasan: batasPenugasan,
        // tugasLat: tugasLat,
        // tugasLng: tugasLng,
        person: person,
        lampiranLat: lampiranLat,
        lampiranLng: lampiranLng,
        note: note,
        // radius: radius.toString(),
      );
      if (result['success'] == true) {
        // update cache lokal segera agar tidak terjadi race condition
        try {
          final box = Hive.box('tugas');
          await box.put('batas_penugasan_$id', batasPenugasan);
          await box.put('update_needed_$id', true);
        } catch (e) {
          // debugPrint('Gagal update local Hive setelah updateTugas: $e');
        }

        await fetchTugas(forceRefresh: true);
      }
      return result;
    } catch (e) {
      // debugPrint("Error update tugas: $e");
      return {'success': false, 'message': 'Terjadi kesalahan'};
    } finally {
      _setLoading(false);
    }
  }

  // Hapus tugas
  Future<String?> deleteTugas(int id) async {
    _setLoading(true);
    try {
      final result = await TugasService.deleteTugas(id);
      await fetchTugas(forceRefresh: true);
      filterTugas(_currentSearch);
      return result['message'];
    } catch (e) {
      // debugPrint("Error delete tugas: $e");
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Update status tetap sama
  Future<String?> updateTugasStatus(int id, String status) async {
    try {
      final result = await TugasService.updateStatus(id: id, status: status);
      if (result['success'] == true) await fetchTugas(forceRefresh: true);
      return result['message'];
    } catch (e) {
      return "Terjadi error: $e";
    }
  }

  // Lain-lain tetap sama
  int get todayActiveTask {
    final today = DateTime.now();
    return _tugasList.where((tugas) {
      try {
        final selesai = DateTime.parse(tugas.batasPenugasan);
        return selesai.year == today.year &&
            selesai.month == today.month &&
            selesai.day == today.day;
      } catch (e) {
        return false;
      }
    }).length;
  }

  Map<String, List<double>> getMonthlyData() {
    List<double> target = List.filled(12, 0);
    List<double> attendanceRate = List.filled(12, 0);
    List<double> projectCompletion = List.filled(12, 0);

    for (final tugas in _tugasList) {
      try {
        DateTime? date = DateTime.tryParse(tugas.tanggalPenugasan);
        if (date == null) continue;
        int monthIndex = date.month - 1;
        target[monthIndex] += 1;
        if (tugas.status.toLowerCase() == 'selesai')
          projectCompletion[monthIndex] += 1;
        else
          attendanceRate[monthIndex] += 1;
      } catch (e) {
        // print('Error parsing tugas tanggalPenugasan: $e');
      }
    }

    return {
      'target': target,
      'attendanceRate': attendanceRate,
      'projectCompletion': projectCompletion,
    };
  }
}

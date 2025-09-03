import 'package:flutter/material.dart';
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

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Fetch data tugas
  Future<void> fetchTugas() async {
    _setLoading(true);
    try {
      _tugasList = await TugasService.fetchTugas();
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetch tugas: $e");
    }
    _setLoading(false);
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
        await fetchTugas();
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
        await fetchTugas();
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
      await fetchTugas();
      filterTugas(_currentSearch);
      return result['message'];
    } catch (e) {
      debugPrint("Error delete tugas: $e");
      return null;
    } finally {
      _setLoading(false);
    }
  }
}

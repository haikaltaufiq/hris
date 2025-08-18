import 'package:flutter/material.dart';
import 'package:hr/data/models/tugas_model.dart';
import 'package:hr/data/services/tugas_service.dart';

class TugasProvider extends ChangeNotifier {
  List<TugasModel> _tugasList = [];
  bool _isLoading = false;

  List<TugasModel> get tugasList => _tugasList;
  bool get isLoading => _isLoading;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
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


  Future<Map<String, dynamic>> createTugas({
    required String judul,
    required String jamMulai,
    required String tanggalMulai,
    required String tanggalSelesai,
    required String assignmentMode,
    int? person,
    int? departmentId,
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
  Future<String?> deleteTugas(int id) async {
    _setLoading(true);
    try {
      final result = await TugasService.deleteTugas(id);
      await fetchTugas();
      return result['message'];
    } catch (e) {
      debugPrint("Error delete tugas: $e");
      return null;
    } finally {
      _setLoading(false);
    }
  }
}

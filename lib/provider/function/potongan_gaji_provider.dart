import 'package:flutter/material.dart';
import 'package:hr/data/models/potongan_gaji.dart';
import 'package:hr/data/services/potongan_gaji_service.dart';

class PotonganGajiProvider extends ChangeNotifier {
  List<PotonganGajiModel> _potonganList = [];
  bool _isLoading = false;

  List<PotonganGajiModel> get potonganList => _potonganList;
  bool get isLoading => _isLoading;
  List<PotonganGajiModel> filteredPotonganGajiList = [];
  String _currentSearch = '';

  // ================= Fetch =================
  Future<void> fetchPotonganGaji() async {
    _isLoading = true;
    notifyListeners();

    try {
      _potonganList = await PotonganGajiService.fetchPotonganGaji();
    } catch (e) {
      _potonganList = [];
      rethrow; // bisa ditangani di UI
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterPotonganGaji(String query) {
    if (query.isEmpty) {
      filteredPotonganGajiList.clear();
    } else {
      final lowerQuery = query.toLowerCase();
      filteredPotonganGajiList = potonganList.where((potongan) {
        final nama = (potongan.namaPotongan).toLowerCase();
        final nominal = potongan.nominal.toString().toLowerCase();
        return nama.contains(lowerQuery) || nominal.contains(lowerQuery);
      }).toList();
    }
    notifyListeners();
  }

  // ================= Create =================
  Future<void> createPotonganGaji(PotonganGajiModel potongan) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newPotongan =
          await PotonganGajiService.createPotonganGaji(potongan);
      _potonganList.add(newPotongan);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================= Update =================
  Future<void> updatePotonganGaji(PotonganGajiModel potongan) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await PotonganGajiService.updatePotonganGaji(potongan);
      if (result['success'] == true) {
        final index = _potonganList.indexWhere((p) => p.id == potongan.id);
        if (index != -1) {
          _potonganList[index] = result['data'] as PotonganGajiModel;
        }
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================= Delete =================
  Future<void> deletePotonganGaji(int id, String currentSearch) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await PotonganGajiService.deletePotonganGaji(id);
      await fetchPotonganGaji();
      filterPotonganGaji(_currentSearch);
      if (success) {
        _potonganList.removeWhere((p) => p.id == id);
      } else {
        throw Exception("Gagal menghapus potongan gaji");
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

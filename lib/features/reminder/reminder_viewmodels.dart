import 'package:flutter/foundation.dart';
import 'package:hr/data/models/pengingat_model.dart';
import 'package:hr/data/services/pengingat_service.dart';

class PengingatViewModel extends ChangeNotifier {
  List<ReminderData> _pengingatList = [];
  List<ReminderData> _filteredList = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<ReminderData> get pengingatList => _pengingatList;
  List<ReminderData> get filteredList => _filteredList;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  /// Fetch awal
  Future<void> fetchPengingat() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await PengingatService.fetchPengingat();
      _pengingatList = result;
      _applyFilter();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetchPengingat: $e");
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tambah pengingat
  Future<void> addPengingat(ReminderData reminder) async {
    try {
      final newReminder = await PengingatService.createPengingat(reminder);
      _pengingatList.add(newReminder);
      _applyFilter();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print("Error addPengingat: $e");
      }
    }
  }

  /// Update pengingat
  Future<void> updatePengingat(int id, ReminderData reminder) async {
    try {
      final updated = await PengingatService.updatePengingat(id, reminder);
      final index = _pengingatList.indexWhere((e) => e.id == id);
      if (index != -1) {
        _pengingatList[index] = updated;
        _applyFilter();
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updatePengingat: $e");
      }
    }
  }

  /// Update status
  /// Update status
  Future<void> updateStatus(int id, String newStatus) async {
    try {
      await PengingatService.updateStatus(id, newStatus);
      final index = _pengingatList.indexWhere((e) => e.id == id);
      if (index != -1) {
        final old = _pengingatList[index];
        _pengingatList[index] = ReminderData(
          id: old.id,
          judul: old.judul,
          deskripsi: old.deskripsi,
          status: newStatus,
          tanggalJatuhTempo: old.tanggalJatuhTempo,
          // isi semua field lain dari model ReminderData lo
        );
        _applyFilter();
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updateStatus: $e");
      }
    }
  }

  /// Hapus pengingat
  Future<void> deletePengingat(int id) async {
    try {
      await PengingatService.deletePengingat(id);
      _pengingatList.removeWhere((e) => e.id == id);
      _applyFilter();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print("Error deletePengingat: $e");
      }
    }
  }

  /// Set query search
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  /// Internal filter
  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredList = List.from(_pengingatList);
    } else {
      final lowerQuery = _searchQuery.toLowerCase();
      _filteredList = _pengingatList.where((reminder) {
        return (reminder.judul.toLowerCase().contains(lowerQuery)) ||
            (reminder.deskripsi.toLowerCase().contains(lowerQuery)) ||
            (reminder.status.toLowerCase().contains(lowerQuery));
      }).toList();
    }
  }
}

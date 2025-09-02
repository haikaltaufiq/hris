import 'package:flutter/material.dart';
import 'package:hr/data/models/gaji_model.dart';
import 'package:hr/data/services/gaji_service.dart';

class GajiProvider extends ChangeNotifier {
  List<GajiUser> _gajiList = [];
  String _searchQuery = '';
  String _sortBy = 'nama';
  bool _ascending = true;
  bool _loading = false;
  String? _error;

  List<GajiUser> get gajiList => _gajiList;
  bool get isLoading => _loading;
  String? get error => _error;

  /// Fetch data dari API
  Future<void> fetchGaji() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _gajiList = await GajiService.fetchGaji();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Update search query
  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  /// Update sorting
  void setSorting(String sortBy, bool ascending) {
    _sortBy = sortBy;
    _ascending = ascending;
    notifyListeners();
  }

  /// List yang sudah di-filter + sort
  List<GajiUser> get displayedList {
    List<GajiUser> data = [..._gajiList];

    // filter by nama
    if (_searchQuery.isNotEmpty) {
      data = data
          .where((gaji) =>
              gaji.nama.toLowerCase().contains(_searchQuery) ||
              gaji.gajiPokok.toString().contains(_searchQuery) ||
              gaji.gajiBersih.toString().contains(_searchQuery))
          .toList();
    }

    // sort
    data.sort((a, b) {
      dynamic valueA, valueB;

      switch (_sortBy) {
        case 'nama':
          valueA = a.nama.toLowerCase();
          valueB = b.nama.toLowerCase();
          break;
        case 'gaji_pokok':
          valueA = a.gajiPokok;
          valueB = b.gajiPokok;
          break;
        case 'gaji_bersih':
          valueA = a.gajiBersih;
          valueB = b.gajiBersih;
          break;
        default:
          valueA = a.nama.toLowerCase();
          valueB = b.nama.toLowerCase();
      }

      int result = 0;
      if (valueA is String && valueB is String) {
        result = valueA.compareTo(valueB);
      } else if (valueA is num && valueB is num) {
        result = valueA.compareTo(valueB);
      }

      return _ascending ? result : -result;
    });

    return data;
  }
}

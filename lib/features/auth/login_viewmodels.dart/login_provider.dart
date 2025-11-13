import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hr/data/models/user_model.dart';
import 'package:hr/data/services/user_service.dart';

class UserProvider extends ChangeNotifier {
  // State user saat ini
  UserModel? _user;
  UserModel? get user => _user;

  // List user dari API
  List<UserModel> _users = [];
  List<UserModel> get users => _users;

  // Filtered list user
  List<UserModel> _filteredUsers = []; // List hasil search
  List<UserModel> get filteredUsers =>
      _currentSearch.isEmpty ? _users : _filteredUsers;

  String _currentSearch = '';

  // Status UI
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Fitur yang diizinkan untuk user
  List<String> _features = [];
  List<String> get features => _features;

  // ===== Helper getter =====
  bool get isLoggedIn => _user != null;
  int get roleId => _user?.peran?.id ?? 0;
  String get roleName => _user?.peran?.namaPeran ?? 'Guest';

  final _userbox = Hive.box('user');
  bool _hasCache = false;
  bool get hasCache => _hasCache;

  int get totalUsers => _users.length;

  String _currentSortField = 'nama';
  String get currentSortField => _currentSortField;

  void sortUsers(String field) {
    _currentSortField = field;

    // Tentukan list mana yang diurutkan (filtered atau full)
    List<UserModel> listToSort =
        _currentSearch.isEmpty ? [..._users] : [..._filteredUsers];

    switch (field) {
      case 'nama':
        listToSort.sort(
            (a, b) => a.nama.toLowerCase().compareTo(b.nama.toLowerCase()));
        break;

      case 'jabatan':
        listToSort.sort((a, b) => (a.jabatan?.namaJabatan ?? '')
            .toLowerCase()
            .compareTo((b.jabatan?.namaJabatan ?? '').toLowerCase()));
        break;

      case 'departemen':
        listToSort.sort((a, b) => (a.departemen?.namaDepartemen ?? '')
            .toLowerCase()
            .compareTo((b.departemen?.namaDepartemen ?? '').toLowerCase()));
        break;

      case 'peran':
        listToSort.sort((a, b) => (a.peran?.namaPeran ?? '')
            .toLowerCase()
            .compareTo((b.peran?.namaPeran ?? '').toLowerCase()));
        break;

      case 'terbaru':
        // kalau model user punya field createdAt / id, kamu bisa pakai itu
        listToSort.sort((a, b) => b.id.compareTo(a.id));
        break;

      case 'terlama':
        listToSort.sort((a, b) => a.id.compareTo(b.id));
        break;

      default:
        break;
    }

    if (_currentSearch.isEmpty) {
      _users = listToSort;
    } else {
      _filteredUsers = listToSort;
    }

    notifyListeners();
  }

  // ===== User setter =====

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  bool hasFeature(dynamic featureId) {
    if (featureId is String) {
      return _features.contains(featureId);
    } else if (featureId is List<String>) {
      // cek kalau ada salah satu ada di _features
      return featureId.any((f) => _features.contains(f));
    }
    return false;
  }

  void clearUser() {
    _user = null;
    _features = [];
    notifyListeners();
  }

  /// Load cache immediately (synchronous)
  void loadCacheFirst() {
    try {
      final hasCache = _userbox.containsKey('user_list');
      if (hasCache) {
        final cached = _userbox.get('user_list') as List;
        if (cached.isNotEmpty) {
          _users = cached
              .map(
                  (json) => UserModel.fromJson(Map<String, dynamic>.from(json)))
              .toList();
          _hasCache = true;
          notifyListeners(); // Update UI immediately
          // print(' Cache loaded: ${_users.length} items');
        }
      }
    } catch (e) {
      print(' Error loading cache: $e');
    }
  }

  // ===== CRUD Users =====
  Future<void> fetchUsers({bool forceRefresh = false}) async {
    // print(' fetchUsers called - forceRefresh: $forceRefresh');

    // Load cache first if not force refresh
    if (!forceRefresh && _users.isEmpty) {
      loadCacheFirst();
    }

    _isLoading = true;
    notifyListeners();

    try {
      // print(' Calling API...');
      final apiData = await UserService.fetchUsers();
      // print(' API success: ${apiData.length} items');

      _users = apiData;
      _filteredUsers.clear();
      _errorMessage = null;

      // Save to cache
      await _userbox.put(
        'user_list',
        _users.map((c) => c.toJson()).toList(),
      );
      // print(' Cache saved');

      _hasCache = true;
    } catch (e) {
      // print(' API Error: $e');
      _errorMessage = e.toString();

      // If no data and cache exists, load cache
      if (_users.isEmpty) {
        loadCacheFirst();
      }
    }

    _isLoading = false;
    notifyListeners();
    // print(' fetchUsers completed - items: ${_users.length}');
  }

  Future<void> createUser(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await UserService.createUser(data);
      await fetchUsers(forceRefresh: true); // refresh list
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUser(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await UserService.updateUser(id, data);
      await fetchUsers(forceRefresh: true); // refresh list
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteUser(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await UserService.deleteUser(id);
      await fetchUsers(forceRefresh: true); // refresh list
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===== Searching =====
  void searchUsers(String query) {
    _currentSearch = query.trim().toLowerCase();

    if (_currentSearch.isEmpty) {
      _filteredUsers = [];
    } else {
      _filteredUsers = _users.where((user) {
        final nama = user.nama.toLowerCase();
        final email = user.email.toLowerCase();
        final jenisKelamin = user.jenisKelamin.toLowerCase();
        final statusNikah = user.statusPernikahan.toLowerCase();
        final jabatan = user.jabatan?.namaJabatan.toLowerCase() ?? '';
        final peran = user.peran?.namaPeran.toLowerCase() ?? '';
        final departemen = user.departemen?.namaDepartemen.toLowerCase() ?? '';
        final gajiPokok = user.gajiPokok?.toLowerCase() ?? '';
        final npwp = user.npwp?.toLowerCase() ?? '';
        final bpjsKes = user.bpjsKesehatan?.toLowerCase() ?? '';
        final bpjsKet = user.bpjsKetenagakerjaan?.toLowerCase() ?? '';

        return nama.contains(_currentSearch) ||
            email.contains(_currentSearch) ||
            jenisKelamin.contains(_currentSearch) ||
            statusNikah.contains(_currentSearch) ||
            jabatan.contains(_currentSearch) ||
            peran.contains(_currentSearch) ||
            departemen.contains(_currentSearch) ||
            gajiPokok.contains(_currentSearch) ||
            npwp.contains(_currentSearch) ||
            bpjsKes.contains(_currentSearch) ||
            bpjsKet.contains(_currentSearch);
      }).toList();
    }

    notifyListeners();
  }

  void clearSearch() {
    _currentSearch = '';
    _filteredUsers = [];
    notifyListeners();
  }
}

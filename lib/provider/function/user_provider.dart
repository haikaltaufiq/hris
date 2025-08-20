import 'package:flutter/material.dart';
import 'package:hr/data/models/user_model.dart';
import 'package:hr/data/services/user_service.dart';
import 'package:hr/provider/features/features_ids.dart';

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
  int get roleId => _user?.peran.id ?? 0;
  String get roleName => _user?.peran.namaPeran ?? 'Guest';

  bool hasFeature(String featureId) => _features.contains(featureId);

  // ===== User setter =====
  void setUser(UserModel user) {
    _user = user;

    if (roleName == "Super Admin" || roleName == "Admin Office") {
      _features = [
        ...FeatureIds.manageCuti,
        ...FeatureIds.manageLembur,
        ...FeatureIds.dashboard,
      ];
    } else {
      _features = [
        ...FeatureIds.userCuti,
        ...FeatureIds.userLembur,
        ...FeatureIds.dashboardUser,
      ];
      // Bisa tambah fetch fitur khusus role dari DB/API kalau perlu
    }

    notifyListeners();
  }

  void clearUser() {
    _user = null;
    _features = [];
    notifyListeners();
  }

  // ===== CRUD Users =====
  Future<void> fetchUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _users = await UserService.fetchUsers();
      // Reset search setiap fetch baru
      _filteredUsers = [];
      _currentSearch = '';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createUser(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await UserService.createUser(data);
      await fetchUsers(); // refresh list
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
      await fetchUsers(); // refresh list
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
      await fetchUsers(); // refresh list
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
        final peran = user.peran.namaPeran.toLowerCase();
        final departemen = user.departemen.namaDepartemen.toLowerCase();
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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/data/models/user_model.dart';
import 'package:hr/data/services/tracking_service.dart';

/// Extension for responsive check
extension ResponsiveContext on BuildContext {
  bool get isMobile => MediaQuery.of(this).size.width < 600;
  bool get isTablet =>
      MediaQuery.of(this).size.width >= 600 &&
      MediaQuery.of(this).size.width < 1024;
  bool get isDesktop => MediaQuery.of(this).size.width >= 1024;
}

/// Main location tracking page for monitoring all users
class LocationTrackPage extends StatefulWidget {
  const LocationTrackPage({super.key});

  @override
  State<LocationTrackPage> createState() => _LocationTrackPageState();
}

class _LocationTrackPageState extends State<LocationTrackPage> {
  List<UserModel> users = [];
  List<UserModel> filteredUsers = [];
  Timer? _timer;
  bool loading = true;
  String filterStatus = 'all';
  final MapController mapController = MapController();
  bool isListExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startAutoRefresh();
  }

  /// Start automatic data refresh every minute
  void _startAutoRefresh() {
    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _loadData(),
    );
  }

  /// Load tracking data from service
  Future<void> _loadData() async {
    try {
      setState(() => loading = true);

      final result = await TrackingService.getTrackingUsers();

      if (mounted) {
        setState(() {
          users = result;
          _applyFilter();
          loading = false;
        });

        debugPrint('Data loaded: ${users.length} users');
        debugPrint('Active: ${users.where((u) => u.isGpsActive).length}');
        debugPrint('Inactive: ${users.where((u) => !u.isGpsActive).length}');
      }
    } catch (e) {
      debugPrint('Error loading data: $e');

      if (mounted) {
        setState(() => loading = false);
        _showErrorSnackbar(e.toString());
      }
    }
  }

  /// Apply filter based on selected status
  void _applyFilter() {
    setState(() {
      if (filterStatus == 'all') {
        filteredUsers = users;
      } else if (filterStatus == 'active') {
        filteredUsers = users.where((u) => u.isGpsActive).toList();
      } else {
        filteredUsers = users.where((u) => !u.isGpsActive).toList();
      }
    });
  }

  /// Show error message to user
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gagal memuat data: $message'),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Coba Lagi',
          textColor: AppColors.putih,
          onPressed: _loadData,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LatLng center = filteredUsers.isNotEmpty &&
            filteredUsers.first.latitude != null &&
            filteredUsers.first.longitude != null
        ? LatLng(filteredUsers.first.latitude!, filteredUsers.first.longitude!)
        : const LatLng(-6.200000, 106.816666);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: context.isMobile ? _buildMobileAppBar() : null,
      body: loading
          ? _buildLoadingState()
          : context.isMobile
              ? _buildMobileLayout(center)
              : _buildWebLayout(center),
    );
  }

  /// Build mobile app bar with actions
  PreferredSizeWidget _buildMobileAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      title: Text(
        'Tracking Lokasi',
        style: TextStyle(
          color: AppColors.putih,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: AppColors.putih),
          onPressed: _loadData,
          tooltip: 'Refresh Data',
        ),
        IconButton(
          icon: Icon(
            isListExpanded ? Icons.map : Icons.list,
            color: AppColors.putih,
          ),
          onPressed: () {
            setState(() {
              isListExpanded = !isListExpanded;
            });
          },
          tooltip: isListExpanded ? 'Tampilkan Map' : 'Tampilkan List',
        ),
      ],
    );
  }

  /// Build mobile layout
  Widget _buildMobileLayout(LatLng center) {
    return Column(
      children: [
        _buildStatsCard(),
        const SizedBox(height: 18),
        _buildFilterChips(),
        const SizedBox(height: 4),
        Expanded(
          child: isListExpanded ? _buildUserListView() : _buildMapView(center),
        ),
      ],
    );
  }

  /// Build web layout with side panel
  Widget _buildWebLayout(LatLng center) {
    return Row(
      children: [
        /// Left panel - Map
        Expanded(
          child: _buildMapView(center),
        ),

        /// Right panel - Stats and user list
        Container(
          width: 400,
          decoration: BoxDecoration(
            color: AppColors.latar3,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(2, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              _buildStatsCard(),
              const SizedBox(height: 18),
              _buildFilterChips(),
              const SizedBox(height: 8),
              Expanded(child: _buildUserListView()),
            ],
          ),
        ),
      ],
    );
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.putih),
          ),
          const SizedBox(height: 16),
          Text(
            'Memuat data tracking...',
            style: TextStyle(
              color: AppColors.putih,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Build statistics card
  Widget _buildStatsCard() {
    final activeCount = users.where((u) => u.isGpsActive).length;
    final inactiveCount = users.length - activeCount;
    final isMobile = context.isMobile;

    return Container(
      margin: EdgeInsets.fromLTRB(
        isMobile ? 16 : 12,
        isMobile ? 16 : 12,
        isMobile ? 16 : 12,
        0,
      ),
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.people,
            label: 'Total',
            value: '${users.length}',
          ),
          _buildStatDivider(),
          _buildStatItem(
            icon: Icons.check_circle,
            label: 'Aktif',
            value: '$activeCount',
          ),
          _buildStatDivider(),
          _buildStatItem(
            icon: Icons.cancel,
            label: 'Tidak Aktif',
            value: '$inactiveCount',
          ),
        ],
      ),
    );
  }

  /// Build individual stat item
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.putih, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.putih,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.putih.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  /// Build divider between stat items
  Widget _buildStatDivider() {
    return Container(
      height: 50,
      width: 1,
      color: AppColors.putih.withOpacity(0.3),
    );
  }

  /// Build filter chips
  Widget _buildFilterChips() {
    final isMobile = context.isMobile;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(child: _buildFilterChip('Semua', 'all')),
          Expanded(child: _buildFilterChip('Aktif', 'active')),
          Expanded(child: _buildFilterChip('Tidak Aktif', 'inactive')),
        ],
      ),
    );
  }

  /// Build individual filter chip
  Widget _buildFilterChip(String label, String value) {
    final isSelected = filterStatus == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          filterStatus = value;
          _applyFilter();
        });
      },
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.putih : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primary : AppColors.putih,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  /// Build map view with markers
  Widget _buildMapView(LatLng center) {
    final isMobile = context.isMobile;

    return Container(
      margin: isMobile ? const EdgeInsets.all(16) : EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: isMobile ? BorderRadius.circular(12) : BorderRadius.zero,
        boxShadow: isMobile
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 14,
              minZoom: 5,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.hr',
              ),
              MarkerLayer(
                markers: filteredUsers
                    .where((u) => u.latitude != null && u.longitude != null)
                    .map(
                      (user) => Marker(
                        width: 80,
                        height: 80,
                        point: LatLng(user.latitude!, user.longitude!),
                        child: GestureDetector(
                          onTap: () => _showUserInfo(user),
                          child: _buildMarker(user),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          if (!isMobile) ...[
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.all(Radius.circular(14))),
                child: IconButton(
                  icon: Icon(Icons.refresh, color: AppColors.putih),
                  onPressed: _loadData,
                  tooltip: 'Refresh Data',
                ),
              ),
            ),
          ],
          if (filteredUsers.isEmpty) _buildEmptyMapOverlay(),
        ],
      ),
    );
  }

  /// Build custom marker for user
  Widget _buildMarker(UserModel user) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: user.isGpsActive ? Colors.green : AppColors.bg,
            border: Border.all(
              color: AppColors.putih,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              user.nama.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: AppColors.putih,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Text(
            user.nama.split(' ').first,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.putih,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Build empty map overlay
  Widget _buildEmptyMapOverlay() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_off,
              size: 48,
              color: AppColors.putih,
            ),
            const SizedBox(height: 12),
            Text(
              'Tidak ada data lokasi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.putih,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pilih filter lain atau refresh data',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.putih,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build user list view
  Widget _buildUserListView() {
    if (filteredUsers.isEmpty) {
      return _buildEmptyListState();
    }

    final isMobile = context.isMobile;

    return ListView.builder(
      padding: EdgeInsets.all(isMobile ? 16 : 12),
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        return _buildUserCard(user);
      },
    );
  }

  /// Build empty list state
  Widget _buildEmptyListState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: AppColors.putih,
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada data user',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.putih,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pilih filter lain atau refresh data',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.putih,
            ),
          ),
        ],
      ),
    );
  }

  /// Build user card for list view
  Widget _buildUserCard(UserModel user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showUserInfo(user),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildUserAvatar(user),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildUserDetails(user),
                ),
                _buildUserActions(user),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build user avatar with status indicator
  Widget _buildUserAvatar(UserModel user) {
    return Stack(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: user.isGpsActive ? Colors.green : AppColors.bg,
          ),
          child: Center(
            child: Text(
              user.nama.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: AppColors.putih,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: user.isGpsActive ? Colors.green : AppColors.bg,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.putih, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  /// Build user details section
  Widget _buildUserDetails(UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user.nama,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.putih,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              user.isGpsActive ? Icons.gps_fixed : Icons.gps_off,
              size: 14,
              color: AppColors.putih.withOpacity(0.8),
            ),
            const SizedBox(width: 4),
            Text(
              user.isGpsActive ? 'GPS Aktif' : 'GPS Tidak Aktif',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.putih.withOpacity(0.8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'Update: ${user.lastUpdate}',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.putih.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  /// Build user action button
  Widget _buildUserActions(UserModel user) {
    if (user.latitude == null || user.longitude == null) {
      return Icon(
        Icons.info_outline,
        color: AppColors.putih.withOpacity(0.5),
      );
    }

    final isMobile = context.isMobile;

    return IconButton(
      icon: Icon(
        Icons.location_searching,
        color: AppColors.putih,
      ),
      onPressed: () {
        if (isMobile) {
          setState(() {
            isListExpanded = false;
          });
          Future.delayed(const Duration(milliseconds: 100), () {
            mapController.move(
              LatLng(user.latitude!, user.longitude!),
              16,
            );
            Future.delayed(const Duration(milliseconds: 300), () {
              _showUserInfo(user);
            });
          });
        } else {
          mapController.move(
            LatLng(user.latitude!, user.longitude!),
            16,
          );
          Future.delayed(const Duration(milliseconds: 300), () {
            _showUserInfo(user);
          });
        }
      },
      tooltip: 'Lihat di Map',
    );
  }

  /// Show user information bottom sheet
  void _showUserInfo(UserModel user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSheetHandle(),
            const SizedBox(height: 16),
            _buildUserInfoAvatar(user),
            const SizedBox(height: 16),
            _buildUserInfoName(user),
            const SizedBox(height: 12),
            _buildUserInfoStatus(user),
            const SizedBox(height: 24),
            _buildUserInfoDetails(user),
            if (!user.isGpsActive) ...[
              const SizedBox(height: 16),
              _buildUserInfoWarning(),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Build bottom sheet handle
  Widget _buildSheetHandle() {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.putih.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  /// Build user info avatar
  Widget _buildUserInfoAvatar(UserModel user) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: user.isGpsActive ? Colors.green : AppColors.bg,
      ),
      child: Center(
        child: Text(
          user.nama.substring(0, 1).toUpperCase(),
          style: TextStyle(
            color: AppColors.putih,
            fontWeight: FontWeight.bold,
            fontSize: 36,
          ),
        ),
      ),
    );
  }

  /// Build user info name
  Widget _buildUserInfoName(UserModel user) {
    return Text(
      user.nama,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.putih,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Build user info status badge
  Widget _buildUserInfoStatus(UserModel user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.putih.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.putih,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            user.isGpsActive ? Icons.gps_fixed : Icons.gps_off,
            size: 16,
            color: AppColors.putih,
          ),
          const SizedBox(width: 6),
          Text(
            user.isGpsActive ? 'GPS Aktif' : 'GPS Tidak Aktif',
            style: TextStyle(
              color: AppColors.putih,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Build user info details section
  Widget _buildUserInfoDetails(UserModel user) {
    return Column(
      children: [
        _buildInfoRow(
          Icons.access_time,
          'Terakhir Update',
          user.lastUpdate != null
              ? DateFormat('dd MMM yyyy, HH:mm').format(user.lastUpdate!)
              : '-',
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          Icons.location_on,
          'Koordinat',
          user.latitude != null && user.longitude != null
              ? '${user.latitude!.toStringAsFixed(6)}, ${user.longitude!.toStringAsFixed(6)}'
              : 'Tidak tersedia',
        ),
      ],
    );
  }

  /// Build info row for details
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.putih.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.putih),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.putih.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.putih,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build warning message for inactive GPS
  Widget _buildUserInfoWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'User belum mengupdate lokasi. GPS mungkin mati atau aplikasi tidak terbuka.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.putih.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

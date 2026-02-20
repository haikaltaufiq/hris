import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hr/core/background_location/track.dart';
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
  bool _isServiceRunning = false;

  /// Controls whether the map occupies the full screen.
  bool _isMapFullscreen = false;

  @override
  void initState() {
    super.initState();
    _checkServiceStatus();
    _loadData();
    _startAutoRefresh();
  }

  /// Check local tracking service status
  Future<void> _checkServiceStatus() async {
    if (!kIsWeb) {
      final serviceStatus = await Track.isRunning();
      if (mounted) {
        setState(() => _isServiceRunning = serviceStatus);
      }
    }
  }

  void _startAutoRefresh() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _loadData(),
    );
  }

  /// Load tracking data from backend API
  Future<void> _loadData() async {
    try {
      if (mounted) setState(() => loading = true);

      if (!kIsWeb) {
        final serviceStatus = await Track.isRunning();
        setState(() => _isServiceRunning = serviceStatus);
      }

      final List<UserModel> result = await TrackingService.getTrackingUsers();

      if (mounted) {
        setState(() {
          users = result;
          _applyFilter();
          loading = false;
        });

        debugPrint('Loaded ${result.length} users from backend');
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
        filteredUsers =
            users.where((u) => u.isGpsActive(_isServiceRunning)).toList();
      } else {
        filteredUsers =
            users.where((u) => !u.isGpsActive(_isServiceRunning)).toList();
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

  /// Toggle fullscreen map mode.
  void _toggleMapFullscreen() {
    setState(() {
      _isMapFullscreen = !_isMapFullscreen;
    });
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

    // Fullscreen map replaces the entire scaffold body.
    if (_isMapFullscreen) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: _buildMapContent(center),
            ),
            // Exit fullscreen button — bottom-right.
            Positioned(
              bottom: 24,
              right: 16,
              child: _MapActionButton(
                icon: Icons.fullscreen_exit,
                tooltip: 'Keluar fullscreen',
                onTap: _toggleMapFullscreen,
              ),
            ),
          ],
        ),
      );
    }

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

  // ================= APP BAR =================

  PreferredSizeWidget _buildMobileAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tracking Lokasi',
            style: TextStyle(
              color: AppColors.putih,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            _isServiceRunning ? 'Service Active' : 'Service Inactive',
            style: TextStyle(
              color: AppColors.putih.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: AppColors.putih),
          onPressed: () {
            _loadData();
            _checkServiceStatus();
          },
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

  // ================= LAYOUTS =================

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

  Widget _buildWebLayout(LatLng center) {
    return Row(
      children: [
        Expanded(
          child: _buildMapView(center),
        ),
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

  // ================= LOADING =================

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
            style: TextStyle(color: AppColors.putih, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ================= STATS =================

  Widget _buildStatsCard() {
    final activeCount =
        users.where((u) => u.isGpsActive(_isServiceRunning)).length;
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
            color: Colors.green,
          ),
          _buildStatDivider(),
          _buildStatItem(
            icon: Icons.cancel,
            label: 'Tidak Aktif',
            value: '$inactiveCount',
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color ?? AppColors.putih, size: 28),
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

  Widget _buildStatDivider() {
    return Container(
      height: 50,
      width: 1,
      color: AppColors.putih.withOpacity(0.3),
    );
  }

  // ================= FILTER =================

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

  // ================= MAP =================

  /// Wraps [_buildMapContent] inside a styled container with a fullscreen button.
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
          // Map tiles and markers.
          Positioned.fill(
            child: _buildMapContent(center),
          ),

          // Refresh button — top-right (web only).
          if (!isMobile)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.all(Radius.circular(14)),
                ),
                child: IconButton(
                  icon: Icon(Icons.refresh, color: AppColors.putih),
                  onPressed: () {
                    _loadData();
                    _checkServiceStatus();
                  },
                  tooltip: 'Refresh Data',
                ),
              ),
            ),

          // Fullscreen button — bottom-right.
          Positioned(
            bottom: 12,
            right: 12,
            child: _MapActionButton(
              icon: Icons.fullscreen,
              tooltip: 'Fullscreen map',
              onTap: _toggleMapFullscreen,
            ),
          ),

          if (filteredUsers.isEmpty) _buildEmptyMapOverlay(),
        ],
      ),
    );
  }

  /// Pure map widget — reused in both normal and fullscreen modes.
  Widget _buildMapContent(LatLng center) {
    return FlutterMap(
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
    );
  }

  Widget _buildMarker(UserModel user) {
    final isActive = user.isGpsActive(_isServiceRunning);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.green : Colors.grey,
            border: Border.all(color: AppColors.putih, width: 3),
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
              user.initial,
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
            color: isActive ? Colors.green : Colors.grey,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Text(
            user.firstName,
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
            Icon(Icons.location_off, size: 48, color: AppColors.putih),
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
              style: TextStyle(fontSize: 12, color: AppColors.putih),
            ),
          ],
        ),
      ),
    );
  }

  // ================= USER LIST =================

  Widget _buildUserListView() {
    if (filteredUsers.isEmpty) return _buildEmptyListState();

    final isMobile = context.isMobile;

    return ListView.builder(
      padding: EdgeInsets.all(isMobile ? 16 : 12),
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) => _buildUserCard(filteredUsers[index]),
    );
  }

  Widget _buildEmptyListState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: AppColors.putih),
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
            style: TextStyle(fontSize: 14, color: AppColors.putih),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    user.isGpsActive(_isServiceRunning);

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
                Expanded(child: _buildUserDetails(user)),
                _buildUserActions(user),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar(UserModel user) {
    final isActive = user.isGpsActive(_isServiceRunning);

    return Stack(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.green : Colors.grey,
          ),
          child: Center(
            child: Text(
              user.initial,
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
              color: isActive ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.putih, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserDetails(UserModel user) {
    final isActive = user.isGpsActive(_isServiceRunning);

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
              isActive ? Icons.gps_fixed : Icons.gps_off,
              size: 14,
              color: isActive ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              isActive ? 'GPS Aktif' : 'GPS Tidak Aktif',
              style: TextStyle(
                fontSize: 12,
                color: isActive ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'Update: ${user.formattedLastUpdate}',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.putih.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildUserActions(UserModel user) {
    if (user.latitude == null || user.longitude == null) {
      return Icon(Icons.info_outline, color: AppColors.putih.withOpacity(0.5));
    }

    final isMobile = context.isMobile;

    return IconButton(
      icon: Icon(Icons.location_searching, color: AppColors.putih),
      onPressed: () {
        if (isMobile) {
          setState(() => isListExpanded = false);
          Future.delayed(const Duration(milliseconds: 100), () {
            mapController.move(LatLng(user.latitude!, user.longitude!), 16);
            Future.delayed(const Duration(milliseconds: 300), () {
              _showUserInfo(user);
            });
          });
        } else {
          mapController.move(LatLng(user.latitude!, user.longitude!), 16);
          Future.delayed(const Duration(milliseconds: 300), () {
            _showUserInfo(user);
          });
        }
      },
      tooltip: 'Lihat di Map',
    );
  }

  // ================= BOTTOM SHEET =================

  void _showUserInfo(UserModel user) {
    final isActive = user.isGpsActive(_isServiceRunning);

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
            if (!isActive) ...[
              const SizedBox(height: 16),
              _buildUserInfoWarning(),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

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

  Widget _buildUserInfoAvatar(UserModel user) {
    final isActive = user.isGpsActive(_isServiceRunning);

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.green : Colors.grey,
      ),
      child: Center(
        child: Text(
          user.initial,
          style: TextStyle(
            color: AppColors.putih,
            fontWeight: FontWeight.bold,
            fontSize: 36,
          ),
        ),
      ),
    );
  }

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

  Widget _buildUserInfoStatus(UserModel user) {
    final isActive = user.isGpsActive(_isServiceRunning);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withOpacity(0.2)
            : Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? Colors.green : Colors.grey,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.gps_fixed : Icons.gps_off,
            size: 16,
            color: isActive ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? 'GPS Aktif' : 'GPS Tidak Aktif',
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

  Widget _buildUserInfoDetails(UserModel user) {
    return Column(
      children: [
        _buildInfoRow(
          Icons.access_time,
          'Terakhir Update',
          user.formattedLastUpdate,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          Icons.location_on,
          'Koordinat',
          user.koordinatString,
        ),
      ],
    );
  }

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

// ================= MAP ACTION BUTTON =================

/// Reusable floating button for map overlay actions.
class _MapActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _MapActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        elevation: 4,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(
              icon,
              size: 22,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

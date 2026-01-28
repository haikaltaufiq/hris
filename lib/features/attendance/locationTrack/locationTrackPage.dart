import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/data/models/user_model.dart';
import 'package:hr/data/services/tracking_service.dart';

class Locationtrackpage extends StatefulWidget {
  const Locationtrackpage({super.key});

  @override
  State<Locationtrackpage> createState() => _LocationtrackpageState();
}

class _LocationtrackpageState extends State<Locationtrackpage> {
  List<UserModel> users = [];
  List<UserModel> filteredUsers = [];
  Timer? _timer;
  bool loading = true;
  String filterStatus = 'all'; // all, active, inactive
  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadData();

    // 🔁 auto refresh tiap 1 menit
    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _loadData(),
    );
  }

  // Di _LocationtrackpageState
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
        
        debugPrint('✅ Data loaded: ${users.length} users');
        debugPrint('📍 Aktif: ${users.where((u) => u.isGpsActive).length}');
        debugPrint('📍 Tidak Aktif: ${users.where((u) => !u.isGpsActive).length}');
      }
    } catch (e) {
      debugPrint('❌ Error loading data: $e');
      
      if (mounted) {
        setState(() => loading = false);
        
        // Tampilkan error ke user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Coba Lagi',
              textColor: Colors.white,
              onPressed: _loadData,
            ),
          ),
        );
      }
    }
  }

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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LatLng center = filteredUsers.isNotEmpty
        ? LatLng(filteredUsers.first.latitude!, filteredUsers.first.longitude!)
        : const LatLng(-6.200000, 106.816666);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // 🗺️ Map
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
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.hr',
                    ),
                    MarkerLayer(
                      markers: filteredUsers
                          .where((u) =>
                              u.latitude != null && u.longitude != null)
                          .map(
                            (user) => Marker(
                              width: 80,
                              height: 80,
                              point: LatLng(user.latitude!, user.longitude!),
                              child: GestureDetector(
                                onTap: () => _showInfo(user),
                                child: _buildCustomMarker(user),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),

                // 📊 Top Info Card
                Positioned(
                  top: 50,
                  left: 16,
                  right: 16,
                  child: _buildTopInfoCard(),
                ),

                // 🔽 Bottom Filter Chips
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: _buildFilterChips(),
                ),

                // 📋 User List Button (Floating)
                Positioned(
                  top: 140,
                  right: 16,
                  child: FloatingActionButton(
                    heroTag: 'userlist',
                    mini: true,
                    backgroundColor: Colors.white,
                    onPressed: _showUserList,
                    child: Icon(Icons.people, color: AppColors.primary),
                  ),
                ),

                // 🔄 Refresh Button
                Positioned(
                  top: 200,
                  right: 16,
                  child: FloatingActionButton(
                    heroTag: 'refresh',
                    mini: true,
                    backgroundColor: Colors.white,
                    onPressed: _loadData,
                    child: Icon(Icons.refresh, color: AppColors.primary),
                  ),
                ),
              ],
            ),
    );
  }

  // 🎨 Custom Marker dengan Avatar & Status
  Widget _buildCustomMarker(UserModel user) {
    return Column(
      children: [
        // Avatar dengan border status
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: user.isGpsActive ? Colors.green : Colors.grey,
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
          child: CircleAvatar(
            backgroundColor: user.isGpsActive ? Colors.green : Colors.grey,
            child: Text(
              user.nama.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        // Name Tag
        Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
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
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // 📊 Top Info Card
  Widget _buildTopInfoCard() {
    final activeCount = users.where((u) => u.isGpsActive).length;
    final inactiveCount = users.length - activeCount;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildInfoItem(
              icon: Icons.people,
              label: 'Total User',
              value: '${users.length}',
              color: Colors.blue,
            ),
            _buildInfoItem(
              icon: Icons.check_circle,
              label: 'Aktif',
              value: '$activeCount',
              color: Colors.green,
            ),
            _buildInfoItem(
              icon: Icons.warning_amber_rounded,
              label: 'Tidak Aktif',
              value: '$inactiveCount',
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // 🔽 Filter Chips
  Widget _buildFilterChips() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildFilterChip('Semua', 'all'),
            _buildFilterChip('Aktif', 'active'),
            _buildFilterChip('Tidak Aktif', 'inactive'),
          ],
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // 📋 Show User List
  void _showUserList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daftar Karyawan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${filteredUsers.length} orang',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            // List
            Expanded(
              child: ListView.builder(
                controller: controller,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return _buildUserListItem(user);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserListItem(UserModel user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: user.isGpsActive ? Colors.green : Colors.grey,
              child: Text(
                user.nama.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: user.isGpsActive ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        title: Text(
          user.nama,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  user.isGpsActive ? Icons.gps_fixed : Icons.gps_off,
                  size: 14,
                  color: user.isGpsActive ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  user.isGpsActive ? 'GPS Aktif' : 'GPS Tidak Aktif',
                  style: TextStyle(
                    fontSize: 12,
                    color: user.isGpsActive ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Update: ${user.lastUpdate}',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.location_searching, color: Colors.blue),
          onPressed: () {
            Navigator.pop(context);
            mapController.move(
              LatLng(user.latitude!, user.longitude!),
              16,
            );
            Future.delayed(const Duration(milliseconds: 300), () {
              _showInfo(user);
            });
          },
        ),
      ),
    );
  }

  // ℹ️ Show User Info (Bottom Sheet)
  void _showInfo(UserModel user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar Besar
            CircleAvatar(
              radius: 40,
              backgroundColor: user.isGpsActive ? Colors.green : Colors.grey,
              child: Text(
                user.nama.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Nama
            Text(
              user.nama,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: user.isGpsActive
                    ? Colors.green.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: user.isGpsActive ? Colors.green : Colors.grey,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    user.isGpsActive ? Icons.gps_fixed : Icons.gps_off,
                    size: 16,
                    color: user.isGpsActive ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    user.isGpsActive ? 'GPS Aktif' : 'GPS Tidak Aktif',
                    style: TextStyle(
                      color: user.isGpsActive ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Info Details
            _buildDetailRow(Icons.access_time, 'Terakhir Update',
                (user.lastUpdate as String?) ?? '-'),
            const SizedBox(height: 10),
            _buildDetailRow(Icons.location_on, 'Koordinat',
                '${user.latitude?.toStringAsFixed(6)}, ${user.longitude?.toStringAsFixed(6)}'),

            const SizedBox(height: 20),

            // Action Button
            if (!user.isGpsActive)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'User belum mengupdate lokasi. GPS mungkin mati atau aplikasi tidak terbuka.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
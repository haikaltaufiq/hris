import 'package:flutter/material.dart';
import 'package:hr/core/helpers/feature_guard.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/features/attendance/view_model/absen_provider.dart';
import 'package:hr/features/auth/login_viewmodels.dart/login_provider.dart';
import 'package:hr/features/cuti/cuti_viewmodel/cuti_provider.dart';
import 'package:hr/features/lembur/lembur_viewmodel/lembur_provider.dart';
import 'package:hr/routes/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class DashboardData extends StatefulWidget {
  const DashboardData({super.key});

  @override
  State<DashboardData> createState() => _DashboardDataState();
}

class _DashboardDataState extends State<DashboardData> {
  static const double _sectionHeight = 420;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Load data from all providers on initialization
  Future<void> _loadData() async {
    final absenProvider = Provider.of<AbsenProvider>(context, listen: false);
    final cutiProvider = Provider.of<CutiProvider>(context, listen: false);
    final lemburProvider = Provider.of<LemburProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    await Future.wait([
      absenProvider.fetchAbsensi(forceRefresh: true),
      cutiProvider.fetchCuti(forceRefresh: true),
      lemburProvider.fetchLembur(forceRefresh: true),
      userProvider.fetchUsers(forceRefresh: true),
    ]);
  }

  /// Calculate attendance statistics for top 5 users
  List<Map<String, dynamic>> _getTopAttendance(
    AbsenProvider absenProvider,
    UserProvider userProvider,
  ) {
    final Map<int, Map<String, dynamic>> userStats = {};
    final now = DateTime.now();
    final allAbsensi = absenProvider.allAbsensi;

    final currentMonthAbsensi = absenProvider.allAbsensi.where((absen) {
      if (absen.checkinDate == null) return false;

      final date = DateTime.tryParse(
        absen.checkinDate!.replaceAll(' ', 'T'),
      );
      if (date == null) return false;

      return date.year == now.year && date.month == now.month;
    }).toList();

    final totalUsers = userProvider.users.length;

    if (totalUsers == 0 || allAbsensi.isEmpty) return [];

    // Initialize stats for all users
    for (final user in userProvider.users) {
      userStats[user.id] = {
        'userId': user.id,
        'name': user.nama,
        'department': user.departemen?.namaDepartemen ?? '-',
        'totalAbsen': 0,
        'totalHadir': 0,
        'totalTepatWaktu': 0,
      };
    }

    // Calculate attendance from all absensi data

    for (final absen in currentMonthAbsensi) {
      final userId = absen.userId;
      if (userId == null || !userStats.containsKey(userId)) continue;

      userStats[userId]!['totalHadir']++;

      if (absen.status == 'Tepat Waktu') {
        userStats[userId]!['totalTepatWaktu']++;
      }
    }

    // Sort by total hadir, then by tepat waktu
    final sortedUsers = userStats.values.toList()
      ..sort((a, b) {
        final hadirCompare =
            (b['totalHadir'] as int).compareTo(a['totalHadir'] as int);
        if (hadirCompare != 0) return hadirCompare;
        return (b['totalTepatWaktu'] as int)
            .compareTo(a['totalTepatWaktu'] as int);
      });

    // Take top 5 and calculate percentages
    return sortedUsers.take(5).map((user) {
      final totalHadir = user['totalHadir'] as int;
      final totalTepatWaktu = user['totalTepatWaktu'] as int;

      return {
        'name': user['name'],
        'department': user['department'],
        'present': totalHadir,
        'ontime': totalHadir == 0
            ? 0
            : ((totalTepatWaktu / totalHadir) * 100).round(),
      };
    }).toList();
  }

  /// Get pending approval requests (Cuti + Lembur)
  List<Map<String, dynamic>> _getPendingRequests(
    CutiProvider cutiProvider,
    LemburProvider lemburProvider,
  ) {
    final List<Map<String, dynamic>> requests = [];

    // Add pending cuti requests
    for (final cuti in cutiProvider.cutiList) {
      if (cuti.isPending || cuti.isProses) {
        requests.add({
          'type': 'Cuti',
          'employee': cuti.user['nama']?.toString() ?? 'Unknown',
          'date': cuti.tanggal_mulai,
          'id': cuti.id,
          'details': '${cuti.tipe_cuti} - ${cuti.alasan}',
          'dateTime': _parseDate(cuti.tanggal_mulai),
        });
      }
    }

    // Add pending lembur requests
    for (final lembur in lemburProvider.lemburList) {
      if (lembur.isPending || lembur.isProses) {
        requests.add({
          'type': 'Lembur',
          'employee': lembur.user['nama']?.toString() ?? 'Unknown',
          'date': lembur.tanggal,
          'id': lembur.id,
          'details': '${lembur.jamMulai} - ${lembur.jamSelesai}',
          'dateTime': _parseDate(lembur.tanggal),
        });
      }
    }

    // Sort by date (newest first)
    requests.sort((a, b) {
      final dateA = a['dateTime'] as DateTime?;
      final dateB = b['dateTime'] as DateTime?;

      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;

      return dateB.compareTo(dateA);
    });

    return requests.take(10).toList();
  }

  /// Parse date string to DateTime
  DateTime? _parseDate(String date) {
    try {
      return DateTime.parse(date);
    } catch (_) {
      return null;
    }
  }

  /// Format date to readable format
  String _formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('dd MMM yyyy').format(parsedDate);
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Consumer4<AbsenProvider, CutiProvider, LemburProvider, UserProvider>(
      builder: (context, absenProvider, cutiProvider, lemburProvider,
          userProvider, child) {
        final topAttendance = _getTopAttendance(absenProvider, userProvider);
        final requestApproval =
            _getPendingRequests(cutiProvider, lemburProvider);

        return SizedBox(
          height: _sectionHeight,
          child: isDesktop
              ? _buildDesktopLayout(topAttendance, requestApproval)
              : _buildMobileLayout(topAttendance, requestApproval),
        );
      },
    );
  }

  /// Desktop layout (Row with 3:1 ratio)
  Widget _buildDesktopLayout(
    List<Map<String, dynamic>> topAttendance,
    List<Map<String, dynamic>> requestApproval,
  ) {
    final hasApproveLembur = FeatureAccess.has('approve_lembur');
    final hasApproveCuti = FeatureAccess.has('approve_cuti');
    final lihatSemuaAbsensi = FeatureAccess.has('lihat_semua_absensi');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (lihatSemuaAbsensi) ...[
          Expanded(
            flex: 3,
            child: _buildTopAttendanceCard(topAttendance),
          ),
        ],
        if (hasApproveCuti || hasApproveLembur) ...[
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: _buildRequestApprovalCard(requestApproval),
          ),
        ],
      ],
    );
  }

  /// Mobile layout (Column with stacked cards)
  Widget _buildMobileLayout(
    List<Map<String, dynamic>> topAttendance,
    List<Map<String, dynamic>> requestApproval,
  ) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: _sectionHeight,
          child: _buildTopAttendanceCard(topAttendance, isMobile: true),
        ),
        Container(
          height: _sectionHeight,
          child: _buildRequestApprovalCard(requestApproval),
        ),
      ],
    );
  }

  /// Top 5 Attendance Card
  Widget _buildTopAttendanceCard(
    List<Map<String, dynamic>> topAttendance, {
    bool isMobile = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.isIndonesian ? 'Top 5 Kehadiran' : 'Top 5 Attendance',
            style: TextStyle(
              color: AppColors.putih,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            context.isIndonesian
                ? 'User dengan tingkat kehadiran tertinggi'
                : 'User with highest attendance rate',
            style: TextStyle(
              color: AppColors.putih.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: topAttendance.isEmpty
                ? _buildEmptyState(context.isIndonesian
                    ? 'Belum ada data kehadiran'
                    : 'No data available')
                : isMobile
                    ? _buildMobileAttendanceTable(topAttendance)
                    : _buildDesktopAttendanceTable(topAttendance),
          ),
        ],
      ),
    );
  }

  /// Desktop Attendance Table with horizontal scroll
  Widget _buildDesktopAttendanceTable(List<Map<String, dynamic>> data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(AppColors.primary),
              dataRowColor: MaterialStateProperty.all(AppColors.primary),
              dividerThickness: 0,
              columns: [
                DataColumn(
                  label: Text(
                    context.isIndonesian ? 'Nama' : 'Name',
                    style: TextStyle(
                      color: AppColors.putih,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    context.isIndonesian ? 'Departemen' : 'Department',
                    style: TextStyle(
                      color: AppColors.putih,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    context.isIndonesian ? 'Total Hadir' : 'Total Present ',
                    style: TextStyle(
                      color: AppColors.putih,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    context.isIndonesian ? 'Tepat Waktu  (%)' : 'On Time  (%)',
                    style: TextStyle(
                      color: AppColors.putih,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
              rows: data.map((e) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        e['name'],
                        style: TextStyle(color: AppColors.putih, fontSize: 12),
                      ),
                    ),
                    DataCell(
                      Text(
                        e['department'],
                        style: TextStyle(color: AppColors.putih, fontSize: 12),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${e['present']}',
                        style: TextStyle(color: AppColors.putih, fontSize: 12),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${e['ontime']}%',
                        style: TextStyle(color: AppColors.putih, fontSize: 12),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  /// Mobile Attendance Table
  Widget _buildMobileAttendanceTable(List<Map<String, dynamic>> data) {
    return SingleChildScrollView(
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(AppColors.primary),
        dataRowColor: MaterialStateProperty.all(AppColors.primary),
        dividerThickness: 0,
        headingTextStyle: TextStyle(
          color: AppColors.putih,
          fontWeight: FontWeight.bold,
        ),
        dataTextStyle: TextStyle(color: AppColors.putih),
        columns: [
          DataColumn(
            label: Text(
              context.isIndonesian ? 'Nama' : 'Name',
              style: TextStyle(
                color: AppColors.putih,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              context.isIndonesian ? 'Departemen' : 'Department',
              style: TextStyle(
                color: AppColors.putih,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              context.isIndonesian ? 'Total Hadir' : 'Total Present ',
              style: TextStyle(
                color: AppColors.putih,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              context.isIndonesian ? 'Tepat Waktu (%)' : 'On Time  (%)',
              style: TextStyle(
                color: AppColors.putih,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
        rows: data.map((e) {
          return DataRow(
            cells: [
              DataCell(Text(
                e['name'],
                style: TextStyle(fontSize: 10),
              )),
              DataCell(Text(
                e['department'],
                style: TextStyle(fontSize: 10),
              )),
              DataCell(Text(
                '${e['present']}',
                style: TextStyle(fontSize: 10),
              )),
              DataCell(Text(
                '${e['ontime']}%',
                style: TextStyle(fontSize: 10),
              )),
            ],
          );
        }).toList(),
      ),
    );
  }

  /// Request Approval Card
  Widget _buildRequestApprovalCard(List<Map<String, dynamic>> requests) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Request Approval',
            style: TextStyle(
              color: AppColors.putih,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Pengajuan yang butuh persetujuan',
            style: TextStyle(
              color: AppColors.putih.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: requests.isEmpty
                ? _buildEmptyState('Tidak ada pengajuan pending')
                : ListView.separated(
                    itemCount: requests.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = requests[index];
                      final bool isCuti = item['type'] == 'Cuti';

                      final Color badgeColor =
                          AppColors.yellow.withOpacity(0.9);

                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          if (isCuti) {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.leave,
                              arguments: item['id'],
                            );
                          } else {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.overTime,
                              arguments: item['id'],
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              // LEFT CONTENT
                              Expanded(
                                child: Tooltip(
                                  message: context.isIndonesian
                                      ? 'Klik untuk setujui pengajuan'
                                      : 'Click to approve request',
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['employee'],
                                        style: TextStyle(
                                          color: AppColors.putih,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${item['type']} • ${_formatDate(item['date'])}',
                                        style: TextStyle(
                                          color:
                                              AppColors.putih.withOpacity(0.7),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // BADGE
                              Tooltip(
                                message: context.isIndonesian
                                    ? 'Klik untuk setujui pengajuan'
                                    : 'Click to approve request',
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: badgeColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    context.isIndonesian
                                        ? 'Menunggu'
                                        : 'Waiting',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Empty state widget
  Widget _buildEmptyState(String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(
          color: AppColors.putih.withOpacity(0.6),
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

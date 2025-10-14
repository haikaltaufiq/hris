import 'package:flutter/material.dart';
import 'package:hr/components/custom/loading.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/data/services/log_service.dart';

class WebTabelLog extends StatefulWidget {
  final String? searchQuery; // Terima query dari parent

  const WebTabelLog({super.key, this.searchQuery});

  @override
  State<WebTabelLog> createState() => _WebTabelLogState();
}

class _WebTabelLogState extends State<WebTabelLog> {
  List<Map<String, dynamic>> activityLogs = [];
  bool isLoading = true;
  String? errorMessage;
  Set<String> expandedUsers = {};
  Set<int> selectedLogs = {};
  Map<String, bool> userShowAll = {};
  final int itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadActivityLogs();
  }

  @override
  void didUpdateWidget(WebTabelLog oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload data jika search query berubah
    if (oldWidget.searchQuery != widget.searchQuery) {
      setState(() {});
    }
  }

  Future<void> _loadActivityLogs() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final logs = await ActivityLogService.fetchActivityLogs();
      setState(() {
        activityLogs = logs;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  // Filter logs berdasarkan search query
  List<Map<String, dynamic>> get filteredLogs {
    if (widget.searchQuery == null || widget.searchQuery!.isEmpty) {
      return activityLogs;
    }

    final query = widget.searchQuery!.toLowerCase();
    return activityLogs.where((log) {
      final user = (log['user'] as String).toLowerCase();
      final action = (log['action'] as String).toLowerCase();
      final module = (log['module'] as String).toLowerCase();
      final description = (log['description'] as String).toLowerCase();
      final timestamp = (log['created_at'] as String).toLowerCase();

      return user.contains(query) ||
          action.contains(query) ||
          module.contains(query) ||
          description.contains(query) ||
          timestamp.contains(query);
    }).toList();
  }

  Map<String, List<Map<String, dynamic>>> get groupedLogs {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var log in filteredLogs) {
      final user = log['user'] as String;
      if (!grouped.containsKey(user)) grouped[user] = [];
      grouped[user]!.add(log);
    }
    grouped.forEach((_, value) {
      value.sort((a, b) => b['id'].compareTo(a['id']));
    });
    return grouped;
  }

  void _toggleUserExpansion(String userName) {
    setState(() {
      if (expandedUsers.contains(userName)) {
        expandedUsers.remove(userName);
      } else {
        expandedUsers.add(userName);
      }
    });
  }

  void _toggleShowAll(String userName) {
    setState(() {
      userShowAll[userName] = !(userShowAll[userName] ?? false);
    });
  }

  Color getActionColor(String action) {
    if (action.toLowerCase().contains('menambah') ||
        action.toLowerCase().contains('tambah')) {
      return Colors.blue;
    }
    if (action.toLowerCase().contains('mengubah') ||
        action.toLowerCase().contains('ubah') ||
        action.toLowerCase().contains('edit') ||
        action.toLowerCase().contains('update')) {
      return Colors.orange;
    }
    if (action.toLowerCase().contains('menolak') ||
        action.toLowerCase().contains('tolak') ||
        action.toLowerCase().contains('reject')) {
      return Colors.red;
    }
    if (action.toLowerCase().contains('menyetujui') ||
        action.toLowerCase().contains('setuju') ||
        action.toLowerCase().contains('approve')) {
      return Colors.green;
    }
    if (action.toLowerCase().contains('mengajukan') ||
        action.toLowerCase().contains('ajukan') ||
        action.toLowerCase().contains('submit')) {
      return Colors.purple;
    }
    if (action.toLowerCase().contains('check in') ||
        action.toLowerCase().contains('checkin')) {
      return Colors.teal;
    }
    if (action.toLowerCase().contains('check out') ||
        action.toLowerCase().contains('checkout')) {
      return Colors.indigo;
    }
    if (action.toLowerCase().contains('upload') ||
        action.toLowerCase().contains('lampiran')) {
      return Colors.cyan;
    }
    if (action.toLowerCase().contains('hapus') ||
        action.toLowerCase().contains('delete')) {
      return Colors.red.shade700;
    }
    return Colors.grey;
  }

  IconData getActionIcon(String action) {
    if (action.toLowerCase().contains('menambah') ||
        action.toLowerCase().contains('tambah'))
      return Icons.add_circle_outline;
    if (action.toLowerCase().contains('mengubah') ||
        action.toLowerCase().contains('ubah') ||
        action.toLowerCase().contains('edit') ||
        action.toLowerCase().contains('update')) return Icons.edit_outlined;
    if (action.toLowerCase().contains('menolak') ||
        action.toLowerCase().contains('tolak') ||
        action.toLowerCase().contains('reject')) return Icons.cancel_outlined;
    if (action.toLowerCase().contains('menyetujui') ||
        action.toLowerCase().contains('setuju') ||
        action.toLowerCase().contains('approve'))
      return Icons.check_circle_outline;
    if (action.toLowerCase().contains('mengajukan') ||
        action.toLowerCase().contains('ajukan') ||
        action.toLowerCase().contains('submit')) return Icons.send_outlined;
    if (action.toLowerCase().contains('check in') ||
        action.toLowerCase().contains('checkin')) return Icons.login_outlined;
    if (action.toLowerCase().contains('check out') ||
        action.toLowerCase().contains('checkout')) return Icons.logout_outlined;
    if (action.toLowerCase().contains('upload') ||
        action.toLowerCase().contains('lampiran'))
      return Icons.attach_file_outlined;
    if (action.toLowerCase().contains('hapus') ||
        action.toLowerCase().contains('delete')) return Icons.delete_outline;
    return Icons.info_outline;
  }

  List<Map<String, dynamic>> getDisplayLogs(
      String userName, List<Map<String, dynamic>> userLogs) {
    final showAll = userShowAll[userName] ?? false;
    if (showAll || userLogs.length <= itemsPerPage) {
      return userLogs;
    }
    return userLogs.take(itemsPerPage).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingWidget(),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('Gagal memuat data'),
            SizedBox(height: 8),
            Text(errorMessage!),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadActivityLogs,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    final grouped = groupedLogs;

    if (activityLogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(context.isIndonesian
                ? 'Belum ada activity log'
                : 'No Activity'),
          ],
        ),
      );
    }

    if (grouped.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(context.isIndonesian
                ? 'Tidak ada hasil pencarian'
                : 'No Search Results'),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Section
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24, left: 10),
                child: Row(
                  children: [
                    Icon(Icons.analytics_outlined,
                        color: AppColors.putih, size: 25),
                    const SizedBox(width: 8),
                    Text(
                      context.isIndonesian
                          ? 'Total ${filteredLogs.length} aktivitas dari ${grouped.length} user'
                          : 'Total ${filteredLogs.length} activity from ${grouped.length} user',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // User Activity Lists
        ...grouped.entries.map((entry) {
          final userName = entry.key;
          final userLogs = entry.value;
          final isExpanded = expandedUsers.contains(userName);
          final showAll = userShowAll[userName] ?? false;
          final displayLogs = getDisplayLogs(userName, userLogs);
          final hasMoreLogs = userLogs.length > itemsPerPage;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Header
              InkWell(
                onTap: () => _toggleUserExpansion(userName),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary,
                        radius: 18,
                        child: Text(
                          userName.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            color: AppColors.putih,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        userName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.putih,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          height: 1,
                          color: Colors.grey.shade300,
                        ),
                      ),
                      Text(
                        '${userLogs.length} Activity',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.putih,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppColors.putih,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

              // Activity List
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: isExpanded
                    ? Padding(
                        padding: const EdgeInsets.only(left: 40, bottom: 16),
                        child: Column(
                          children: [
                            ...displayLogs.asMap().entries.map((entry) {
                              final index = entry.key;
                              final log = entry.value;
                              final actionColor = getActionColor(log['action']);
                              final actionIcon = getActionIcon(log['action']);
                              final isLast = index == displayLogs.length - 1;

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      Icon(
                                        actionIcon,
                                        color: actionColor,
                                        size: 16,
                                      ),
                                      if (!isLast || (hasMoreLogs && !showAll))
                                        Container(
                                          width: 1,
                                          height: 50,
                                          color: Colors.grey.shade300,
                                          margin: const EdgeInsets.only(top: 4),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        bottom: (isLast &&
                                                (!hasMoreLogs || showAll))
                                            ? 0
                                            : 16,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                log['action'],
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: actionColor,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                ),
                                                child: Text(
                                                  log['module'],
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            log['description'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: AppColors.putih,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            log['created_at'] ?? '',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                            if (hasMoreLogs)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.more_horiz,
                                      color: Colors.grey.shade400,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 12),
                                    InkWell(
                                      onTap: () => _toggleShowAll(userName),
                                      borderRadius: BorderRadius.circular(6),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                            color: AppColors.primary
                                                .withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              showAll
                                                  ? 'Sembunyikan'
                                                  : 'Lihat ${userLogs.length - itemsPerPage} lainnya',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppColors.putih,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Icon(
                                              showAll
                                                  ? Icons.keyboard_arrow_up
                                                  : Icons.keyboard_arrow_down,
                                              color: AppColors.putih,
                                              size: 16,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              if (entry != grouped.entries.last) const SizedBox(height: 8),
            ],
          );
        }).toList(),
      ],
    );
  }
}

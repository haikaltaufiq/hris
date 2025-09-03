import 'package:flutter/material.dart';
import 'package:hr/data/services/log_service.dart';

class WebPageLog extends StatefulWidget {
  const WebPageLog({super.key});

  @override
  State<WebPageLog> createState() => _WebPageLogState();
}

class _WebPageLogState extends State<WebPageLog> {
  List<Map<String, dynamic>> activityLogs = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadActivityLogs();
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

  Map<String, List<Map<String, dynamic>>> get groupedLogs {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var log in activityLogs) {
      final user = log['user'] as String;
      if (!grouped.containsKey(user)) grouped[user] = [];
      grouped[user]!.add(log);
    }
    grouped.forEach((_, value) {
      value.sort((a, b) => b['id'].compareTo(a['id']));
    });
    return grouped;
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
        action.toLowerCase().contains('tambah')) {
      return Icons.add_circle;
    }
    if (action.toLowerCase().contains('mengubah') ||
        action.toLowerCase().contains('ubah') ||
        action.toLowerCase().contains('edit') ||
        action.toLowerCase().contains('update')) {
      return Icons.edit;
    }
    if (action.toLowerCase().contains('menolak') ||
        action.toLowerCase().contains('tolak') ||
        action.toLowerCase().contains('reject')) {
      return Icons.cancel;
    }
    if (action.toLowerCase().contains('menyetujui') ||
        action.toLowerCase().contains('setuju') ||
        action.toLowerCase().contains('approve')) {
      return Icons.check_circle;
    }
    if (action.toLowerCase().contains('mengajukan') ||
        action.toLowerCase().contains('ajukan') ||
        action.toLowerCase().contains('submit')) {
      return Icons.send;
    }
    if (action.toLowerCase().contains('check in') ||
        action.toLowerCase().contains('checkin')) {
      return Icons.login;
    }
    if (action.toLowerCase().contains('check out') ||
        action.toLowerCase().contains('checkout')) {
      return Icons.logout;
    }
    if (action.toLowerCase().contains('upload') ||
        action.toLowerCase().contains('lampiran')) {
      return Icons.attach_file;
    }
    if (action.toLowerCase().contains('hapus') ||
        action.toLowerCase().contains('delete')) {
      return Icons.delete;
    }
    return Icons.info;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat activity log...'),
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

    if (activityLogs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Belum ada activity log'),
          ],
        ),
      );
    }

    final grouped = groupedLogs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Card
        Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.analytics, color: Colors.blue.shade600, size: 24),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total ${activityLogs.length} aktivitas',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'dari ${grouped.length} user',
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // User Logs
        ...grouped.entries.map((entry) {
          final userName = entry.key;
          final userLogs = entry.value;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header User
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.indigo.shade600, Colors.indigo.shade400],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Text(
                          userName.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            color: Colors.indigo.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${userLogs.length} aktivitas',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // List Log Activities
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: userLogs.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 16),
                  itemBuilder: (context, index) {
                    final log = userLogs[index];
                    final actionColor = getActionColor(log['action']);
                    final actionIcon = getActionIcon(log['action']);

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: actionColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(actionIcon, color: actionColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: actionColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      log['action'],
                                      style: TextStyle(
                                        color: actionColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      log['module'],
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                log['description'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    log['created_at'] ?? '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}

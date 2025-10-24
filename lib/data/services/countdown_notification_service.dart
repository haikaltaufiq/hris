// ignore_for_file: prefer_final_fields

import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class CountdownNotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  Timer? _timer;
  Set<int> _milestonesFired = {}; // Track milestone yang sudah dijalankan

  CountdownNotificationService(this.flutterLocalNotificationsPlugin);

  void startCountdown(DateTime batasWaktu, String tugasJudul, int tugasId) {
    _timer?.cancel();
    _milestonesFired.clear();

    final totalDuration = batasWaktu.difference(DateTime.now()).inSeconds;
    int elapsed = 0;

    _showCountdownNotification(
        tugasId, tugasJudul, totalDuration, elapsed, batasWaktu);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      elapsed++;
      final remaining = batasWaktu.difference(DateTime.now());

      if (!remaining.isNegative) {
        final remainingSeconds = remaining.inSeconds;
        _checkMilestone(tugasId, tugasJudul, remainingSeconds);
      }

      // update tampilan countdown (termasuk overtime)
      _showCountdownNotification(
          tugasId, tugasJudul, totalDuration, elapsed, batasWaktu);
    });
  }

  void _checkMilestone(int id, String title, int remainingSeconds) {
    // Milestone: 30 menit, 10 menit, 5 menit, 1 menit
    final milestones = [1800, 600, 300, 60]; // dalam detik

    for (var milestone in milestones) {
      if (remainingSeconds <= milestone &&
          remainingSeconds > milestone - 5 &&
          !_milestonesFired.contains(milestone)) {
        _milestonesFired.add(milestone);
        _showMilestoneNotification(id + 1000, title, milestone);
        break;
      }
    }
  }

  Future<void> _showMilestoneNotification(
      int id, String title, int milestoneSeconds) async {
    String timeText;
    String emoji;

    switch (milestoneSeconds) {
      case 1800:
        timeText = '30 menit';
        emoji = '⏰';
        break;
      case 600:
        timeText = '10 menit';
        emoji = '⚠️';
        break;
      case 300:
        timeText = '5 menit';
        emoji = '🔥';
        break;
      case 60:
        timeText = '1 menit';
        emoji = '🚨';
        break;
      default:
        return;
    }

    final androidDetails = AndroidNotificationDetails(
      'milestone_channel',
      'Peringatan Milestone',
      channelDescription: 'Notifikasi peringatan waktu tersisa',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      autoCancel: true, // milestone bisa digeser (boleh dihapus)
      styleInformation: BigTextStyleInformation(
        'Tinggal $timeText lagi untuk menyelesaikan tugas ini! Segera selesaikan ya! 💪',
        htmlFormatBigText: true,
        contentTitle: '$emoji Peringatan: $title',
        htmlFormatContentTitle: true,
      ),
      color: Color(_getMilestoneColor(milestoneSeconds)),
    );

    final notifDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      id,
      '$emoji Peringatan: $title',
      'Tinggal $timeText lagi!',
      notifDetails,
    );
  }

  int _getMilestoneColor(int seconds) {
    if (seconds <= 60) return const Color(0xFFFF0000).value; // Merah
    if (seconds <= 300) return const Color(0xFFFF6B00).value; // Orange
    if (seconds <= 600) return const Color(0xFFFFAA00).value; // Orange muda
    return const Color(0xFF2196F3).value; // Biru
  }

  Future<void> _showCountdownNotification(
    int id,
    String title,
    int totalSeconds,
    int elapsedSeconds,
    DateTime batasWaktu,
  ) async {
    final now = DateTime.now();
    final difference = batasWaktu.difference(now);
    final isOvertime = difference.isNegative;

    int timeValue =
        isOvertime ? difference.inSeconds.abs() : difference.inSeconds;
    final hours = (timeValue ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((timeValue % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (timeValue % 60).toString().padLeft(2, '0');

    String emoji;
    String timeText;
    String urgencyText;

    if (isOvertime) {
      emoji = '🚨';
      timeText = '-$hours:$minutes:$seconds';
      urgencyText = '⚠️ TERLAMBAT! Tugas sudah melewati batas waktu';
    } else {
      emoji = _getTimeEmoji(timeValue);
      timeText = '$hours:$minutes:$seconds';
      urgencyText = _getUrgencyText(timeValue);
    }

    final body = '$emoji Sisa waktu: $timeText\n$urgencyText';

    final androidDetails = AndroidNotificationDetails(
      'countdown_channel',
      'Countdown Tugas',
      channelDescription: 'Notifikasi countdown untuk tugas',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true, // ✅ Tidak bisa digeser/hapus manual
      autoCancel: false, // ✅ Tetap muncul sampai tugas selesai
      onlyAlertOnce: true,
      showProgress: !isOvertime,
      maxProgress: totalSeconds,
      progress: isOvertime ? 0 : elapsedSeconds.clamp(0, totalSeconds),
      showWhen: false,
      enableVibration: false,
      playSound: false,
      styleInformation: BigTextStyleInformation(
        body,
        htmlFormatBigText: true,
        contentTitle: '📋 $title',
        htmlFormatContentTitle: true,
        summaryText: isOvertime
            ? 'TERLAMBAT'
            : _getProgressPercentage(totalSeconds, elapsedSeconds),
      ),
      color: isOvertime
          ? const Color(0xFFFF0000)
          : Color(_getProgressColor(totalSeconds, elapsedSeconds)),
    );

    final notifDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notifDetails,
    );
  }

  String _getTimeEmoji(int remaining) {
    if (remaining <= 60) return '🚨';
    if (remaining <= 300) return '🔥';
    if (remaining <= 600) return '⚠️';
    if (remaining <= 1800) return '⏰';
    return '⏳';
  }

  String _getUrgencyText(int remaining) {
    if (remaining <= 60) return '⚡ SEGERA! Waktunya hampir habis!';
    if (remaining <= 300) return '💨 Buruan! Tinggal sebentar lagi!';
    if (remaining <= 600) return '👀 Jangan lupa, masih ada waktu sedikit';
    if (remaining <= 1800) return '📌 Tetap fokus pada tugas ini';
    return '✨ Masih banyak waktu, kerjakan dengan tenang';
  }

  String _getProgressPercentage(int total, int elapsed) {
    final percentage =
        ((elapsed / total) * 100).clamp(0, 100).toStringAsFixed(0);
    return '$percentage% selesai';
  }

  int _getProgressColor(int total, int elapsed) {
    final remaining = total - elapsed;
    if (remaining <= 60) return const Color(0xFFFF0000).value; // Merah
    if (remaining <= 300) return const Color(0xFFFF6B00).value; // Orange
    if (remaining <= 1800) return const Color(0xFFFFAA00).value; // Orange muda
    return const Color(0xFF4CAF50).value; // Hijau
  }

// Di CountdownNotificationService
  Future<void> stopCountdown() async {
    _timer?.cancel();
    _timer = null;
    // tambahin delay mikro buat pastiin thread lama selesai
    await Future.delayed(Duration(milliseconds: 50));
  }
}

// ignore_for_file: prefer_final_fields

import 'dart:async';
import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class _CountdownState {
  Timer? timer;
  Set<int> milestonesFired = {};
  int totalSeconds = 0;
  int elapsed = 0;
  DateTime? batasWaktu;
  String? title;
}

class CountdownNotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  CountdownNotificationService(this.flutterLocalNotificationsPlugin);

  // central store: one state per tugasId
  static final Map<int, _CountdownState> _states = {};

  /// Start or restart countdown for a specific tugasId.
  /// This will cancel any existing countdown for the same tugasId first.
  Future<void> startCountdown(
      DateTime batasWaktu, String tugasJudul, int tugasId) async {
    // cancel existing for this tugasId (if any)
    await stopCountdown(tugasId: tugasId);

    final state = _CountdownState()
      ..batasWaktu = batasWaktu
      ..title = tugasJudul;

    final now = DateTime.now();
    final total = batasWaktu.difference(now).inSeconds;
    state.totalSeconds = total > 0 ? total : 0;
    state.elapsed = 0;
    _states[tugasId] = state;

    // ensure any existing notification with same id removed before showing new ongoing notif
    try {
      await flutterLocalNotificationsPlugin.cancel(tugasId);
    } catch (_) {}

    // show first notification immediately
    await _showCountdownNotificationInternal(tugasId, state);

    state.timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      // if state removed externally stop
      final s = _states[tugasId];
      if (s == null) {
        timer.cancel();
        return;
      }

      s.elapsed++;
      final remaining = s.batasWaktu!.difference(DateTime.now());
      final remainingSeconds = remaining.isNegative ? -remaining.inSeconds : remaining.inSeconds;

      // milestone check only when not overtime (or keep as before)
      if (!remaining.isNegative) {
        _checkMilestoneInternal(tugasId, s, remainingSeconds);
      }

      await _showCountdownNotificationInternal(tugasId, s);
    });
  }

  /// Stop countdown for a specific tugasId.
  /// If tugasId == null -> stop ALL countdowns.
  Future<void> stopCountdown({int? tugasId}) async {
    if (tugasId == null) {
      // stop all
      for (final key in _states.keys.toList()) {
        final s = _states.remove(key);
        s?.timer?.cancel();
        try {
          await flutterLocalNotificationsPlugin.cancel(key);
        } catch (_) {}
      }
      return;
    }

    final s = _states.remove(tugasId);
    s?.timer?.cancel();
    try {
      await flutterLocalNotificationsPlugin.cancel(tugasId);
    } catch (_) {}
    // small delay to let any running callbacks finish
    await Future.delayed(const Duration(milliseconds: 50));
  }

  void _checkMilestoneInternal(
      int tugasId, _CountdownState state, int remainingSeconds) {
    final milestones = [1800, 600, 300, 60];
    for (var m in milestones) {
      if (remainingSeconds <= m &&
          remainingSeconds > m - 5 &&
          !state.milestonesFired.contains(m)) {
        state.milestonesFired.add(m);
        _showMilestoneNotificationInternal(
            tugasId + 1000, state.title ?? 'Tugas', m);
        break;
      }
    }
  }

  Future<void> _showMilestoneNotificationInternal(
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
      autoCancel: true,
      styleInformation: BigTextStyleInformation(
        'Tinggal $timeText lagi untuk menyelesaikan tugas ini! Segera selesaikan ya!',
        htmlFormatBigText: true,
        contentTitle: '$emoji Peringatan: $title',
        htmlFormatContentTitle: true,
      ),
    );

    final notifDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      id,
      '$emoji Peringatan: $title',
      'Tinggal $timeText lagi!',
      notifDetails,
    );
  }

  Future<void> _showCountdownNotificationInternal(
    int id, _CountdownState state) async {
    final now = DateTime.now();
    final difference = state.batasWaktu!.difference(now);
    final isOvertime = difference.isNegative;

    int timeValue = isOvertime ? difference.inSeconds.abs() : difference.inSeconds;
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

    // warna progress bar sesuai status
    Color color;
    if (isOvertime) {
      color = const Color(0xFFFF0000); // merah
    } else if (timeValue <= 300) {
      color = const Color(0xFFFF0000); // merah hampir habis
    } else if (timeValue <= 900) {
      color = const Color(0xFFFFA500); // oranye sedang
    } else {
      color = const Color(0xFF00C853); // hijau masih lama
    }

    final body = '$emoji Sisa waktu: $timeText\n$urgencyText';

    final totalSeconds = state.totalSeconds;
    final elapsed = state.elapsed.clamp(0, totalSeconds == 0 ? 0 : state.elapsed);

    final androidDetails = AndroidNotificationDetails(
      'countdown_channel',
      'Countdown Tugas',
      channelDescription: 'Notifikasi countdown untuk tugas',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,
      showProgress: !isOvertime && totalSeconds > 0,
      maxProgress: totalSeconds > 0 ? totalSeconds : 0,
      progress: (!isOvertime && totalSeconds > 0) ? elapsed : 0,
      color: color,
      colorized: true,
      showWhen: false,
      enableVibration: false,
      playSound: false,
      styleInformation: BigTextStyleInformation(
        body,
        htmlFormatBigText: true,
        contentTitle: '📋 ${state.title}',
        htmlFormatContentTitle: true,
        summaryText: isOvertime
            ? 'TERLAMBAT'
            : _getProgressPercentage(totalSeconds, elapsed),
      ),
    );

    final notifDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      id,
      state.title,
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
    if (total <= 0) return '0% Waktu Berjalan';
    final percentage =
        ((elapsed / total) * 100).clamp(0, 100).toStringAsFixed(0);
    return '$percentage% Waktu Berjalan';
  }
}

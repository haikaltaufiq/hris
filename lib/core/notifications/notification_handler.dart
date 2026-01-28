import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hr/core/notifications/local_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationHandler {
  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    final isValid = await _validateUser(message.data);
    if (!isValid) return;

    await _processNotification(message.data, isBackground: true);
  }

  static Future<void> handleForegroundMessage(RemoteMessage message) async {
    final isValid = await _validateUser(message.data);
    if (!isValid) return;

    await _processNotification(message.data, message: message);
  }

  static Future<bool> _validateUser(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getInt('id');
    final targetUserId = int.tryParse(data['target_id']?.toString() ?? '');

    if (targetUserId != null && targetUserId != currentUserId) {
      return false;
    }

    return true;
  }

  static Future<void> _processNotification(
    Map<String, dynamic> data, {
    RemoteMessage? message,
    bool isBackground = false,
  }) async {
    final tipe = data['tipe'];
    final plugin = LocalNotificationService.plugin;

    switch (tipe) {
      case 'tugas_baru':
      case 'tugas_update':
        await _handleTugasNotification(data, plugin, tipe);
        break;

      case 'tugas_hapus':
      case 'tugas_pindah':
      case 'tugas_selesai':
      case 'tugas_lampiran':
      case 'tugas_lampiran_dikirim':
      case 'tugas_update_proses':
        await _handleTugasAction(data, plugin, tipe);
        break;

      case 'cuti_diajukan':
      case 'cuti_step1':
      case 'cuti_disetujui':
      case 'cuti_ditolak':
      case 'cuti_perlu_approval':
      case 'cuti_perlu_approval_final':
        await _handleCutiNotification(data, plugin, tipe, message);
        break;

      case 'lembur_diajukan':
      case 'lembur_step1':
      case 'lembur_disetujui':
      case 'lembur_ditolak':
      case 'lembur_perlu_approval':
      case 'lembur_perlu_approval_final':
        await _handleLemburNotification(data, plugin, tipe, message);
        break;
    }
  }

  static Future<void> _handleTugasNotification(
    Map<String, dynamic> data,
    dynamic plugin,
    String tipe,
  ) async {
    final tugasId = int.tryParse(data['tugas_id'] ?? '') ?? 0;
    final judul = data['judul'] ?? 'Tugas';
    final batasWaktu = data['batas_penugasan'] != null
        ? DateTime.parse(data['batas_penugasan'])
        : null;

    final title = tipe == 'tugas_baru' ? '📌 Tugas Baru' : '⏰ Tugas Diperbarui';
    final body = tipe == 'tugas_baru'
        ? 'Kamu punya tugas baru: "$judul"${batasWaktu != null ? ', deadline: ${batasWaktu.toLocal()}' : ''}'
        : 'Data tugas "$judul" telah diperbarui oleh admin.';

    await LocalNotificationService.show(
      tugasId.hashCode,
      title,
      body,
      sound: tipe == 'tugas_update',
      vibration: tipe == 'tugas_update',
    );
  }

  static Future<void> _handleTugasAction(
    Map<String, dynamic> data,
    dynamic plugin,
    String tipe,
  ) async {
    final tugasId = int.tryParse(data['tugas_id'] ?? '') ?? 0;
    final judul = data['judul'] ?? 'Tugas';

    String title, body;
    bool sound = false, vibration = false;

    switch (tipe) {
      case 'tugas_hapus':
        title = '❌ Tugas Dihapus';
        body = 'Tugas "$judul" telah dihapus oleh admin.';
        break;
      case 'tugas_pindah':
        title = '👋 Tugas Dipindahkan';
        body = 'Tugas "$judul" telah dipindahkan ke pengguna lain.';
        break;
      case 'tugas_selesai':
        title = '✅ Tugas Selesai - Kerja Bagus!';
        body = 'Selamat! Tugas "$judul" telah disetujui dan diselesaikan.';
        sound = true;
        vibration = true;
        break;
      case 'tugas_lampiran':
        title = '📎 Lampiran Dikirim';
        body = 'User mengirim lampiran untuk tugas "$judul".';
        break;
      case 'tugas_lampiran_dikirim':
        title = '✅ Lampiran Terkirim';
        body =
            'Kamu sudah mengirim lampiran tugas "$judul". Menunggu verifikasi admin.';
        break;
      case 'tugas_update_proses':
        title = '📝 Status Tugas Proses';
        body =
            'Status tugas "$judul" telah diubah menjadi PROSES. Tolong hubungi admin untuk menanyakan kejelasan.';
        sound = true;
        vibration = true;
        break;
      default:
        return;
    }

    await LocalNotificationService.show(
      999000 + tugasId,
      title,
      body,
      sound: sound,
      vibration: vibration,
    );
  }

  static Future<void> _handleCutiNotification(
    Map<String, dynamic> data,
    dynamic plugin,
    String tipe,
    RemoteMessage? message,
  ) async {
    await _handleApprovalNotification(
      data,
      plugin,
      'cuti',
      tipe,
      message,
    );
  }

  static Future<void> _handleLemburNotification(
    Map<String, dynamic> data,
    dynamic plugin,
    String tipe,
    RemoteMessage? message,
  ) async {
    await _handleApprovalNotification(
      data,
      plugin,
      'lembur',
      tipe,
      message,
    );
  }

  static Future<void> _handleApprovalNotification(
    Map<String, dynamic> data,
    dynamic plugin,
    String type,
    String tipe,
    RemoteMessage? message,
  ) async {
    final id = int.tryParse(data['${type}_id'] ?? '') ?? 0;
    final channel = '${type}_channel';
    final channelName =
        type == 'cuti' ? 'Cuti Notifications' : 'Lembur Notifications';

    String title, body;
    bool sound = false, vibration = false;

    final action = tipe.replaceFirst('${type}_', '');

    switch (action) {
      case 'diajukan':
        title = '📝 Pengajuan ${type == 'cuti' ? 'Cuti' : 'Lembur'} Diterima';
        body = type == 'cuti'
            ? 'Pengajuan cuti Anda tanggal ${data['tanggal_mulai']} s/d ${data['tanggal_selesai']} berhasil dikirim.'
            : 'Pengajuan lembur Anda tanggal ${data['tanggal']} berhasil dikirim.';
        break;
      case 'step1':
        title = '✅ ${type == 'cuti' ? 'Cuti' : 'Lembur'} Disetujui Tahap Awal';
        body = type == 'cuti'
            ? 'Cuti Anda tanggal ${data['tanggal_mulai']} s/d ${data['tanggal_selesai']} disetujui tahap awal.'
            : 'Lembur Anda tanggal ${data['tanggal']} disetujui tahap awal.';
        sound = true;
        break;
      case 'disetujui':
        title = '🎉 ${type == 'cuti' ? 'Cuti' : 'Lembur'} Disetujui Final';
        body = type == 'cuti'
            ? 'Selamat! Cuti Anda tanggal ${data['tanggal_mulai']} s/d ${data['tanggal_selesai']} telah disetujui.'
            : 'Selamat! Lembur Anda tanggal ${data['tanggal']} telah disetujui.';
        sound = true;
        vibration = true;
        break;
      case 'ditolak':
        title = '❌ ${type == 'cuti' ? 'Cuti' : 'Lembur'} Ditolak';
        body =
            '${type == 'cuti' ? 'Cuti' : 'Lembur'} Anda ditolak. Catatan: ${data['catatan_penolakan'] ?? '-'}';
        sound = true;
        vibration = true;
        break;
      case 'perlu_approval':
      case 'perlu_approval_final':
        title = message?.notification?.title ??
            '${type == 'cuti' ? 'Cuti' : 'Lembur'} Perlu Persetujuan';
        body = message?.notification?.body ??
            'Ada pengajuan ${type == 'cuti' ? 'cuti' : 'lembur'} yang perlu disetujui';
        sound = true;
        vibration = true;
        break;
      default:
        return;
    }

    await LocalNotificationService.show(
      id.hashCode,
      title,
      body,
      channel: channel,
      channelName: channelName,
      sound: sound,
      vibration: vibration,
    );
  }
}

// lib/services/location_background_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hr/data/api/api_config.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const String _kChannelId = 'location_service_channel';
const String _kChannelName = 'Location Tracking Service';
const String _kChannelDesc = 'Background location tracking for attendance';
const String _kNotifIcon = 'ic_notif_tracking';
const int _kNotifId = 888;
const int _kLogLimit = 100;
const int _kTrackingIntervalSeconds = 5;

// ---------------------------------------------------------------------------
// iOS background handler
// ---------------------------------------------------------------------------

/// Handles background execution lifecycle on iOS.
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();

  final log = prefs.getStringList('location_log') ?? <String>[];
  log.add(DateTime.now().toIso8601String());
  await prefs.setStringList('location_log', log);

  return true;
}

// ---------------------------------------------------------------------------
// Background service entry point
// ---------------------------------------------------------------------------

/// Main entry point executed inside the background isolate.
@pragma('vm:entry-point')
void onStartLocationService(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('service_status', 'running');

  final notifications = FlutterLocalNotificationsPlugin();

  // Initialize notifications inside the background isolate
  await notifications.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('ic_launcher_foreground'),
      iOS: DarwinInitializationSettings(),
    ),
  );

  _registerServiceListeners(service);

  Timer.periodic(const Duration(seconds: _kTrackingIntervalSeconds), (_) async {
    if (service is AndroidServiceInstance &&
        await service.isForegroundService()) {
      await _runTrackingCycle(service, notifications, prefs);
    }
  });
}

// ---------------------------------------------------------------------------
// Service event listeners
// ---------------------------------------------------------------------------

/// Registers foreground, background, and stop event listeners.
void _registerServiceListeners(ServiceInstance service) {
  if (service is AndroidServiceInstance) {
    service
        .on('setAsForeground')
        .listen((_) => service.setAsForegroundService());
    service
        .on('setAsBackground')
        .listen((_) => service.setAsBackgroundService());
  }

  service.on('stopService').listen((_) {
    debugPrint('[LocationService] Stop requested — performing checkout.');
    service.stopSelf();
  });
}

// ---------------------------------------------------------------------------
// Tracking cycle
// ---------------------------------------------------------------------------

/// Executes one location tracking cycle: validate state, fetch position, report.
Future<void> _runTrackingCycle(
  AndroidServiceInstance service,
  FlutterLocalNotificationsPlugin notifications,
  SharedPreferences prefs,
) async {
  try {
    // Validate location service availability
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('[LocationService] Location services are disabled.');
      await _showStatusNotification(
        notifications,
        title: 'Location Service Disabled',
        body: 'Enable location services in device settings to resume tracking.',
        color: const Color(0xFFFF6B6B),
        priority: Priority.high,
        importance: Importance.high,
      );
      service.invoke('update', {
        'current_date': DateTime.now().toIso8601String(),
        'error': 'Location services are disabled',
      });
      return;
    }

    // Validate location permission
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      debugPrint('[LocationService] Location permission denied.');
      await _showStatusNotification(
        notifications,
        title: 'Location Permission Required',
        body: 'Grant location permission to enable attendance tracking.',
        color: const Color(0xFFFFA500),
        priority: Priority.high,
        importance: Importance.high,
      );
      service.invoke('update', {
        'current_date': DateTime.now().toIso8601String(),
        'error': 'Location permission denied',
      });
      return;
    }

    // Fetch current position
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final latStr = position.latitude.toStringAsFixed(6);
    final lngStr = position.longitude.toStringAsFixed(6);
    final accStr = position.accuracy.toStringAsFixed(2);
    final timeStr = DateTime.now().toString().substring(11, 19);

    debugPrint(
        '[LocationService] Update — Lat: $latStr | Lng: $lngStr | Acc: ${accStr}m | Time: $timeStr');

    // Transmit location to backend
    await _sendLocationToBackend(position.latitude, position.longitude);

    // Update persistent notification
    await _showStatusNotification(
      notifications,
      title: 'Location Tracking Active',
      body: 'Lat: $latStr  Lng: $lngStr\nAccuracy: ${accStr}m  |  $timeStr',
      color: const Color(0xFF4CAF50),
      priority: Priority.low,
      importance: Importance.low,
    );

    // Persist location log entry
    await _appendLocationLog(prefs, latStr, lngStr, accStr);

    // Resolve device model
    final deviceModel = await _resolveDeviceModel();

    // Broadcast update to foreground UI
    service.invoke('update', {
      'current_date': DateTime.now().toIso8601String(),
      'device': deviceModel,
      'latitude': latStr,
      'longitude': lngStr,
      'accuracy': accStr,
      'timestamp': timeStr,
      'sent_to_backend': true,
    });
  } catch (e) {
    debugPrint('[LocationService] ERROR: $e');

    await _showStatusNotification(
      notifications,
      title: 'Tracking Error',
      body: e.toString().length > 80
          ? '${e.toString().substring(0, 80)}...'
          : e.toString(),
      color: const Color(0xFFFF6B6B),
      priority: Priority.high,
      importance: Importance.high,
    );

    service.invoke('update', {
      'current_date': DateTime.now().toIso8601String(),
      'error': e.toString(),
    });
  }
}

// ---------------------------------------------------------------------------
// Notification helper
// ---------------------------------------------------------------------------

/// Displays or updates the persistent foreground service notification.
Future<void> _showStatusNotification(
  FlutterLocalNotificationsPlugin plugin, {
  required String title,
  required String body,
  required Color color,
  required Priority priority,
  required Importance importance,
}) async {
  await plugin.show(
    _kNotifId,
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        _kChannelId,
        _kChannelName,
        channelDescription: _kChannelDesc,
        icon: _kNotifIcon,
        ongoing: true,
        priority: priority,
        importance: importance,
        color: color,
        showWhen: true,
        styleInformation: BigTextStyleInformation(
          body,
          summaryText:
              'Perform checkout while finish your work hour, to stop location tracking.',
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Backend transmission
// ---------------------------------------------------------------------------

/// Sends the current GPS coordinates to the backend tracking endpoint.
Future<void> _sendLocationToBackend(
  double latitude,
  double longitude,
) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      debugPrint(
          '[LocationService] Auth token missing — skipping backend sync.');
      return;
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/api/tracking/update');

    final response = await http
        .post(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({'latitude': latitude, 'longitude': longitude}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      debugPrint('[LocationService] Location synced successfully.');
    } else {
      debugPrint(
          '[LocationService] Backend error ${response.statusCode}: ${response.body}');
    }
  } on TimeoutException {
    debugPrint('[LocationService] Backend request timed out.');
  } catch (e) {
    debugPrint('[LocationService] Backend sync failed: $e');
  }
}

// ---------------------------------------------------------------------------
// Utility helpers
// ---------------------------------------------------------------------------

/// Appends a location entry to the rolling SharedPreferences log.
Future<void> _appendLocationLog(
  SharedPreferences prefs,
  String lat,
  String lng,
  String acc,
) async {
  final log = prefs.getStringList('location_log') ?? <String>[];
  log.add(
      '${DateTime.now().toIso8601String()} — Lat: $lat, Lng: $lng, Acc: ${acc}m');

  if (log.length > _kLogLimit) {
    log.removeAt(0);
  }

  await prefs.setStringList('location_log', log);
}

/// Returns the device model name on Android, null otherwise.
Future<String?> _resolveDeviceModel() async {
  if (!Platform.isAndroid) return null;

  final info = DeviceInfoPlugin();
  final androidInfo = await info.androidInfo;
  return androidInfo.model;
}

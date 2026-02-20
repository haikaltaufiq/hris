import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hr/core/background_location/entry.dart';
import 'package:hr/data/api/api_config.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service class for managing location tracking
class LocationTrackingService {
  static final LocationTrackingService _instance =
      LocationTrackingService._internal();

  factory LocationTrackingService() => _instance;

  LocationTrackingService._internal();

  final FlutterBackgroundService _service = FlutterBackgroundService();
  bool _isInitialized = false;

  /// Initialize the background location service
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('[TRACK] Service already initialized');
      return;
    }

    debugPrint('[TRACK] Initializing location tracking service...');

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'location_service_channel',
      'Location Tracking Service',
      description: 'Background location tracking for attendance',
      importance: Importance.low,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    if (Platform.isIOS || Platform.isAndroid) {
      await flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(
          iOS: DarwinInitializationSettings(),
          android: AndroidInitializationSettings('ic_launcher_foreground'),
        ),
      );
    }

    if (Platform.isAndroid) {
      final androidPlugin =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(channel);
      debugPrint('[TRACK] Notification channel created');
    }

    await _service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStartLocationService,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'location_service_channel',
        initialNotificationTitle: 'Location Tracking Active',
        initialNotificationContent:
            'Perform checkout while finish your work hour, to stop location tracking.',
        foregroundServiceNotificationId: 888,
        foregroundServiceTypes: [AndroidForegroundType.location],
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStartLocationService,
        onBackground: onIosBackground,
      ),
    );

    _isInitialized = true;
    debugPrint('[TRACK] ✅ Service initialized successfully');
  }

  /// Check if all required permissions are granted
  Future<PermissionStatus> checkPermissions() async {
    final locationStatus = await Permission.location.status;
    final notificationStatus = await Permission.notification.status;
    final locationAlwaysStatus = await Permission.locationAlways.status;

    debugPrint('[PERMISSIONS] Location: ${locationStatus.name}');
    debugPrint('[PERMISSIONS] Notification: ${notificationStatus.name}');
    debugPrint(
        '[PERMISSIONS] Background Location: ${locationAlwaysStatus.name}');

    if (locationStatus.isGranted &&
        notificationStatus.isGranted &&
        locationAlwaysStatus.isGranted) {
      return PermissionStatus.granted;
    }

    return PermissionStatus.denied;
  }

  /// Request all required permissions
  Future<PermissionRequestResult> requestPermissions() async {
    debugPrint('[PERMISSIONS] Requesting permissions...');

    // Request notification permission first
    final notificationStatus = await Permission.notification.request();
    debugPrint('[PERMISSIONS] Notification result: ${notificationStatus.name}');

    // Request location permission
    final locationStatus = await Permission.location.request();
    debugPrint('[PERMISSIONS] Location result: ${locationStatus.name}');

    // If location granted, request background location
    PermissionStatus locationAlwaysStatus = PermissionStatus.denied;
    if (locationStatus.isGranted) {
      locationAlwaysStatus = await Permission.locationAlways.request();
      debugPrint(
          '[PERMISSIONS] Background location result: ${locationAlwaysStatus.name}');
    }

    final allGranted = locationStatus.isGranted &&
        notificationStatus.isGranted &&
        locationAlwaysStatus.isGranted;

    debugPrint(
        '[PERMISSIONS] ${allGranted ? "✅ All granted" : "❌ Some denied"}');

    return PermissionRequestResult(
      granted: allGranted,
      locationStatus: locationStatus,
      notificationStatus: notificationStatus,
      backgroundLocationStatus: locationAlwaysStatus,
    );
  }

  /// Start location tracking service
  Future<bool> start() async {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🚀 STARTING LOCATION TRACKING');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    final prefs = await SharedPreferences.getInstance();
    final baseUrl = await ApiConfig.baseUrl();
    await prefs.setString('base_url', baseUrl);
    if (!_isInitialized) {
      debugPrint('[TRACK] Service not initialized, initializing now...');
      await initialize();
    }

    // Check permissions first
    final permissionStatus = await checkPermissions();
    if (!permissionStatus.isGranted) {
      debugPrint(
          '[TRACK] ⚠️ Permissions not granted. Requesting permissions...');
      final result = await requestPermissions();
      if (!result.granted) {
        debugPrint('[TRACK] ❌ Permissions denied. Cannot start tracking.');
        return false;
      }
    }

    final isRunning = await _service.isRunning();
    if (!isRunning) {
      _service.startService();
      debugPrint('[TRACK] ✅ Location tracking service STARTED');
      return true;
    }

    debugPrint('[TRACK] ⚠️ Location tracking service already running');
    return true;
  }

  /// Stop location tracking service
  Future<bool> stop() async {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🛑 STOPPING LOCATION TRACKING');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    final isRunning = await _service.isRunning();
    if (isRunning) {
      _service.invoke("stopService");
      debugPrint('[TRACK] ✅ Location tracking service STOPPED');
      return true;
    }

    debugPrint('[TRACK] ⚠️ Location tracking service is not running');
    return false;
  }

  /// Check if service is running
  Future<bool> isRunning() async {
    final running = await _service.isRunning();
    debugPrint('[TRACK] Service status: ${running ? "RUNNING" : "STOPPED"}');
    return running;
  }

  /// Get stream of location updates
  Stream<Map<String, dynamic>?> get onLocationUpdate => _service.on('update');
}

/// Result of permission request
class PermissionRequestResult {
  final bool granted;
  final PermissionStatus locationStatus;
  final PermissionStatus notificationStatus;
  final PermissionStatus backgroundLocationStatus;

  PermissionRequestResult({
    required this.granted,
    required this.locationStatus,
    required this.notificationStatus,
    required this.backgroundLocationStatus,
  });

  String get statusMessage => '''
Location: ${locationStatus.name}
Notification: ${notificationStatus.name}
Background Location: ${backgroundLocationStatus.name}
''';
}

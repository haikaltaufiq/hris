import 'package:hr/core/background_location/service.dart';
import 'package:permission_handler/permission_handler.dart';

/// Simple facade class for location tracking
class Track {
  static final LocationTrackingService _service = LocationTrackingService();

  /// Initialize location tracking service
  /// Call this once during app initialization
  static Future<void> initialize() async {
    await _service.initialize();
  }

  /// Start location tracking
  /// Returns true if started successfully
  static Future<bool> start() async {
    return await _service.start();
  }

  /// Stop location tracking
  /// Returns true if stopped successfully
  static Future<bool> stop() async {
    return await _service.stop();
  }

  /// Check if tracking is currently running
  static Future<bool> isRunning() async {
    return await _service.isRunning();
  }

  /// Get stream of location updates
  static Stream<Map<String, dynamic>?> get updates => _service.onLocationUpdate;

  /// Check current permission status
  static Future<PermissionStatus> checkPermissions() async {
    return await _service.checkPermissions();
  }

  /// Request all required permissions
  static Future<PermissionRequestResult> requestPermissions() async {
    return await _service.requestPermissions();
  }
}

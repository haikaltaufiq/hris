import 'dart:async';
import 'package:flutter/foundation.dart';

import 'location_service.dart';
import 'tracking_service.dart';

class LocationTracker {
  static Timer? _timer;

  static void start() {
    debugPrint('⏱ LocationTracker STARTED');

    _timer ??= Timer.periodic(
      const Duration(minutes: 1),
      (_) async {
        debugPrint('⏱ Timer tick — ambil lokasi');

        final position = await LocationService.getCurrentLocation();
        debugPrint('📡 Position: $position');

        if (position != null) {
          await TrackingService.updateLocation(
            latitude: position.latitude,
            longitude: position.longitude,
          );
        } else {
          debugPrint('❌ Position NULL');
        }
      },
    );
  }

  static void stop() {
    _timer?.cancel();
    _timer = null;
  }
}

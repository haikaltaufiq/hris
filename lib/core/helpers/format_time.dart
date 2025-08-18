import 'package:intl/intl.dart';

class FormatTime {
  String formatTime(String time) {
    if (time.isEmpty) return '-';
    try {
      return DateFormat('HH:mm').format(DateFormat('HH:mm:ss').parse(time));
    } catch (_) {
      return time;
    }
  }
}

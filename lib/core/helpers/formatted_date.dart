import 'package:intl/intl.dart';

class DateHelper {
  static String format(String date) {
    if (date.isEmpty) return '-';
    return DateFormat('dd/MM/yyyy').format(DateTime.parse(date));
  }
}

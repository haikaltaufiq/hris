// helper/gaji_helper_web.dart
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class GajiWebHelper {
  static void downloadFile(List<int> bytes, String fileName) {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    // ignore: unused_local_variable
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", fileName)
      ..click();

    html.Url.revokeObjectUrl(url);
  }
}

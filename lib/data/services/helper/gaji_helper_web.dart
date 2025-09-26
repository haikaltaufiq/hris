// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class GajiWebHelper {
  static void downloadFile(List<int> bytes, String fileName) {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    html.Url.revokeObjectUrl(url);
  }
}

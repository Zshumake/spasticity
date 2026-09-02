import 'dart:io';

import 'package:share_plus/share_plus.dart';

/// Write [json] to a file and return the full path it landed at.
///
/// Prefers the user's Downloads folder on desktop, where they will actually
/// look for it. On a phone there is no Downloads folder the user can browse
/// to, and a path in a snackbar is useless there, so the file is written to
/// the temp directory and handed to the share sheet (Files, AirDrop, Mail).
Future<String> saveJson(String json, String filename) async {
  if (Platform.isIOS || Platform.isAndroid) {
    final file = File('${Directory.systemTemp.path}/$filename');
    await file.writeAsString(json, flush: true);
    await SharePlus.instance.share(ShareParams(
      files: [XFile(file.path, mimeType: 'application/json')],
      subject: filename,
    ));
    return file.path;
  }

  final home =
      Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
  Directory dir = Directory.systemTemp;
  if (home != null && home.isNotEmpty) {
    final downloads = Directory('$home${Platform.pathSeparator}Downloads');
    if (downloads.existsSync()) dir = downloads;
  }
  final file = File('${dir.path}${Platform.pathSeparator}$filename');
  await file.writeAsString(json, flush: true);
  return file.path;
}

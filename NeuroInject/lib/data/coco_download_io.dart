import 'dart:io';

/// Write [json] to a file and return the full path it landed at.
///
/// Prefers the user's Downloads folder on desktop, where they will actually
/// look for it; falls back to the temp directory on mobile, where there is no
/// such folder and the path is what gets surfaced instead.
Future<String> saveJson(String json, String filename) async {
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

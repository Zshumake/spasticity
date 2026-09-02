import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Hand [json] to the browser as a downloaded file, and describe where it went.
///
/// Uses an object URL rather than a `data:` URI: data URIs are size-capped in
/// several browsers, and a full training set is comfortably large enough to hit
/// that ceiling.
Future<String> saveJson(String json, String filename) async {
  final bytes = Uint8List.fromList(utf8.encode(json));
  final blob = web.Blob(
    <JSAny>[bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'application/json'),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..download = filename;
  // Must be in the document for the click to count as a user-initiated
  // download in some browsers; removed again immediately.
  web.document.body?.appendChild(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
  return 'your Downloads folder';
}

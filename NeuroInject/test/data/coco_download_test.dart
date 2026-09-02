import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:neuroinject/data/coco_download.dart';

/// Exporting is the only thing standing between a session of hand-drawn
/// highlights and losing them to cleared browser storage, so the write path is
/// tested rather than assumed.
void main() {
  test('writes real, re-readable JSON and reports where it landed', () async {
    const payload = '{"images":[],"annotations":[],"categories":[]}';
    final name = 'neuroinject-test-${DateTime.now().microsecondsSinceEpoch}.json';

    final where = await saveJson(payload, name);

    final file = File(where);
    addTearDown(() {
      if (file.existsSync()) file.deleteSync();
    });

    expect(file.existsSync(), isTrue, reason: 'saveJson returned $where');
    expect(file.readAsStringSync(), payload);
    // Round-trips as JSON — a truncated or double-encoded write would fail here.
    expect(jsonDecode(file.readAsStringSync()), isA<Map<String, dynamic>>());
    expect(where, endsWith(name));
  });

  test('a large export is written whole, not truncated', () async {
    // Realistic size for a full 46-muscle training set with dense polygons.
    final big = jsonEncode({
      'annotations': List.generate(
        400,
        (i) => {'id': i, 'segmentation': List.filled(600, 123.456)},
      ),
    });
    final name = 'neuroinject-big-${DateTime.now().microsecondsSinceEpoch}.json';

    final file = File(await saveJson(big, name));
    addTearDown(() {
      if (file.existsSync()) file.deleteSync();
    });

    expect(file.lengthSync(), big.length);
    expect((jsonDecode(file.readAsStringSync())['annotations'] as List), hasLength(400));
  });
}

import 'dart:convert';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:neuroinject/data/coco_exporter.dart';
import 'package:neuroinject/models/highlight_capture.dart';

HighlightCapture cap(String muscleId, List<Offset> poly, {int t = 1}) =>
    HighlightCapture(
      id: 'cap_$t',
      muscleId: muscleId,
      imageRef: 'assets/images/clinical/$muscleId-us.jpg',
      polygon: poly,
      canvasSize: const Size(320, 240),
      createdAtMillis: t,
    );

// A 100x100 axis-aligned square.
final square = [
  const Offset(10, 20),
  const Offset(110, 20),
  const Offset(110, 120),
  const Offset(10, 120),
];

void main() {
  group('CocoExporter', () {
    test('emits a well-formed COCO dataset', () {
      final coco = CocoExporter.toCoco([cap('fcr', square, t: 5)]);
      expect(coco.keys,
          containsAll(['info', 'images', 'categories', 'annotations']));
      expect((coco['images'] as List), hasLength(1));
      expect((coco['annotations'] as List), hasLength(1));
      expect((coco['categories'] as List), hasLength(1));

      final img = (coco['images'] as List).first as Map;
      expect(img['width'], 320);
      expect(img['height'], 240);
      expect(img['file_name'], 'assets/images/clinical/fcr-us.jpg');

      final ann = (coco['annotations'] as List).first as Map;
      expect(ann['image_id'], img['id']);
      expect(ann['bbox'], [10.0, 20.0, 100.0, 100.0]);
      expect(ann['area'], 10000.0); // 100 x 100 square
      expect(ann['iscrowd'], 0);
      // segmentation is one flat [x,y,...] ring.
      final seg = (ann['segmentation'] as List).first as List;
      expect(seg.length, square.length * 2);
      expect(seg.take(2), [10.0, 20.0]);
    });

    test('builds one category per distinct muscle, ids stable & sorted', () {
      final coco = CocoExporter.toCoco([
        cap('triceps', square, t: 1),
        cap('fcr', square, t: 2),
        cap('fcr', square, t: 3),
      ]);
      final cats = (coco['categories'] as List).cast<Map>();
      expect(cats, hasLength(2));
      // sorted alphabetically -> fcr=1, triceps=2
      expect(cats.firstWhere((c) => c['name'] == 'fcr')['id'], 1);
      expect(cats.firstWhere((c) => c['name'] == 'triceps')['id'], 2);
      expect((coco['annotations'] as List), hasLength(3));
    });

    test('resolves category display names and supercategories', () {
      final coco = CocoExporter.toCoco(
        [cap('fcr', square)],
        categoryName: (id) => 'Flexor Carpi Radialis',
        superCategory: (id) => 'Upper Extremity',
      );
      final c = (coco['categories'] as List).first as Map;
      expect(c['name'], 'Flexor Carpi Radialis');
      expect(c['supercategory'], 'Upper Extremity');
      expect(c['muscleId'], 'fcr');
    });

    test('skips captures with fewer than 3 points', () {
      final coco = CocoExporter.toCoco([
        cap('fcr', [const Offset(0, 0), const Offset(1, 1)], t: 1),
        cap('fcr', square, t: 2),
      ]);
      expect((coco['annotations'] as List), hasLength(1));
    });

    test('toCocoJson is valid, parseable JSON', () {
      final s = CocoExporter.toCocoJson([cap('fcr', square)],
          dateEpochMillis: 42);
      final parsed = json.decode(s) as Map<String, dynamic>;
      expect(parsed['info']['date_created'], 42);
      expect((parsed['annotations'] as List), hasLength(1));
    });
  });
}

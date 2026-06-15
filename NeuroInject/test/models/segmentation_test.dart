import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:neuroinject/models/segmentation.dart';
import 'package:neuroinject/widgets/highlight/structure_legend.dart';

void main() {
  group('PolygonStubSegmenter', () {
    const seg = PolygonStubSegmenter();

    test('returns empty for a too-short stroke', () async {
      final r = await seg.refine(SegmentationInput(
          strokes: [
            [const Offset(0, 0), const Offset(1, 1)]
          ],
          canvasSize: Size.zero));
      expect(r.isEmpty, isTrue);
    });

    test('treats the drawn lasso as the mask polygon', () async {
      final square = [
        const Offset(0, 0),
        const Offset(100, 0),
        const Offset(100, 100),
        const Offset(0, 100),
      ];
      final r = await seg.refine(
          SegmentationInput(strokes: [square], canvasSize: Size.zero));
      expect(r.isEmpty, isFalse);
      expect(r.polygon.length, 4);
      expect(r.polygon.first, const Offset(0, 0));
    });

    test('decimates densely-packed points below minGap', () async {
      // 50 points 1px apart on a line, then a far point — far ones survive.
      final dense = [
        for (var i = 0; i < 50; i++) Offset(i.toDouble(), 0),
        const Offset(200, 0),
        const Offset(200, 200),
      ];
      final r = await seg.refine(
          SegmentationInput(strokes: [dense], canvasSize: Size.zero));
      // Far fewer than 52 kept thanks to the 4px gap filter.
      expect(r.polygon.length, lessThan(20));
    });
  });

  group('StructureKind.classify', () {
    test('arteries, veins, vessels, pleura -> artery (red)', () {
      expect(StructureKind.classify('The radial artery runs lateral'),
          StructureKind.artery);
      expect(StructureKind.classify('small saphenous vein'),
          StructureKind.artery);
      expect(StructureKind.classify('the pleura lies deep'),
          StructureKind.artery);
    });

    test('nerves, plexus, ganglion -> nerve (gold)', () {
      expect(StructureKind.classify('the median nerve lies deep'),
          StructureKind.nerve);
      expect(StructureKind.classify('brachial plexus'), StructureKind.nerve);
    });

    test('bone, periosteum, cortex -> bone (slate)', () {
      expect(StructureKind.classify('avoid the periosteum of the humerus'),
          StructureKind.bone);
      expect(StructureKind.classify('the tibial cortex is medial'),
          StructureKind.bone);
    });

    test('unmatched -> other', () {
      expect(StructureKind.classify('use the smallest possible volume'),
          StructureKind.other);
    });
  });
}

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neuroinject/data/cover_fit.dart';
import 'package:neuroinject/models/structure_kind.dart';
import 'package:neuroinject/models/us_annotation.dart';
import 'package:neuroinject/widgets/highlight/baked_highlight.dart';

/// A presentation crop must move the scan and its mask TOGETHER. The two are
/// pixel-aligned, and the highlight is only meaningful while they stay that
/// way, so the crop is expressed as the source rect of one shared [CoverFit]
/// rather than as a step applied to the scan. These tests pin that: they crop
/// to a region the mask covers and to one it does not, and check the tint
/// follows the anatomy rather than the frame.

const int _w = 64;
const int _h = 32;

/// Grey stripes standing in for speckle: strong local contrast, no colour, so
/// any colour in the output came from the tint.
Future<ui.Image> _stripedScan() {
  final px = Uint8List(_w * _h * 4);
  for (var y = 0; y < _h; y++) {
    for (var x = 0; x < _w; x++) {
      final v = (x % 4 < 2) ? 40 : 200;
      final i = (y * _w + x) * 4;
      px[i] = px[i + 1] = px[i + 2] = v;
      px[i + 3] = 255;
    }
  }
  return _decodeRgba(px);
}

/// Alpha 255 on the LEFT half only.
Future<ui.Image> _halfMask() {
  final px = Uint8List(_w * _h * 4);
  for (var y = 0; y < _h; y++) {
    for (var x = 0; x < _w; x++) {
      final i = (y * _w + x) * 4;
      px[i] = px[i + 1] = px[i + 2] = 255;
      px[i + 3] = x < _w ~/ 2 ? 255 : 0;
    }
  }
  return _decodeRgba(px);
}

Future<ui.Image> _decodeRgba(Uint8List px) {
  final c = Completer<ui.Image>();
  ui.decodeImageFromPixels(px, _w, _h, ui.PixelFormat.rgba8888, c.complete);
  return c.future;
}

Future<ByteData> _render(BakedHighlightPainter painter) async {
  final rec = ui.PictureRecorder();
  painter.paint(Canvas(rec), const Size(_w * 1.0, _h * 1.0));
  final img = await rec.endRecording().toImage(_w, _h);
  return (await img.toByteData(format: ui.ImageByteFormat.rawRgba))!;
}

({int r, int g, int b}) _at(ByteData d, int x, int y) {
  final i = (y * _w + x) * 4;
  return (r: d.getUint8(i), g: d.getUint8(i + 1), b: d.getUint8(i + 2));
}

bool _isGrey(({int r, int g, int b}) p) =>
    (p.r - p.b).abs() <= 2 && (p.r - p.g).abs() <= 2;

const _blue = Color(0xFF3E9BE0);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ui.Image scan;
  late ui.Image mask;

  setUpAll(() async {
    scan = await _stripedScan();
    mask = await _halfMask();
  });

  tearDownAll(() {
    scan.dispose();
    mask.dispose();
  });

  BakedHighlightPainter painter({Rect? crop, List<StructureLabel> labels = const []}) =>
      BakedHighlightPainter(
        scan: scan,
        mask: mask,
        accent: _blue,
        intensity: 1.0,
        crop: crop,
        labels: labels,
        fit: BoxFit.cover,
      );

  group('crop', () {
    test('cropping to the masked half tints the whole visible frame', () async {
      // The left half is entirely under the mask. Crop to it and every visible
      // pixel should carry the tint — which can only be true if the mask was
      // cropped along with the scan.
      final d = await _render(painter(crop: const Rect.fromLTWH(0, 0, 32, 32)));
      for (final x in [4, 20, 40, 60]) {
        expect(_isGrey(_at(d, x, 16)), isFalse,
            reason: 'x=$x should be tinted under a left-half crop');
      }
    });

    test('cropping to the unmasked half tints nothing', () async {
      // The mirror image, and the one that catches a crop applied to the scan
      // but not to its mask: if the mask stayed put, tint would leak in here.
      final d = await _render(painter(crop: const Rect.fromLTWH(32, 0, 32, 32)));
      for (final x in [4, 20, 40, 60]) {
        expect(_isGrey(_at(d, x, 16)), isTrue,
            reason: 'x=$x must stay untinted under a right-half crop');
      }
    });

    test('no crop leaves the original split intact', () async {
      final d = await _render(painter());
      expect(_isGrey(_at(d, 10, 16)), isFalse, reason: 'left half is masked');
      expect(_isGrey(_at(d, 54, 16)), isTrue, reason: 'right half is not');
    });

    test('a crop larger than the frame falls back to the frame', () async {
      final p = painter(crop: const Rect.fromLTWH(-50, -50, 500, 500));
      expect(p.sourceRect(), Rect.fromLTWH(0, 0, _w.toDouble(), _h.toDouble()));
    });
  });

  group('letters', () {
    test('a letter is drawn at its source coordinate', () async {
      final d = await _render(painter(labels: const [
        StructureLabel(
            letter: 'A',
            name: 'Soleus',
            kind: StructureKind.artery,
            point: Offset(32, 16)),
      ]));
      // Inside the puck but clear of the glyph.
      final p = _at(d, 38, 16);
      final want = StructureKind.artery.color;
      expect((p.r - (want.r * 255).round()).abs() < 24, isTrue,
          reason: 'expected the artery colour at the puck, got $p');
      expect(_isGrey(p), isFalse);
    });

    test('a letter outside the crop is not drawn', () async {
      // Letter sits in the left half; crop shows only the right half.
      final d = await _render(painter(
        crop: const Rect.fromLTWH(32, 0, 32, 32),
        labels: const [
          StructureLabel(
              letter: 'A',
              name: 'Soleus',
              kind: StructureKind.artery,
              point: Offset(4, 16)),
        ],
      ));
      for (final x in [4, 20, 40, 60]) {
        expect(_isGrey(_at(d, x, 16)), isTrue,
            reason: 'no puck should appear at x=$x');
      }
    });
  });

  group('CoverFit with a source rect', () {
    test('round-trips points inside the crop', () {
      const box = Size(390, 260);
      const crop = Rect.fromLTWH(120, 60, 400, 300);
      final f = CoverFit.cropped(box, crop);
      for (final src in [
        const Offset(120, 60),
        const Offset(300, 200),
        const Offset(519, 359),
      ]) {
        final back = f.toImage(f.toWidget(src), 960, 720);
        expect(back, isNotNull, reason: 'src $src');
        expect(back!.dx, closeTo(src.dx, 0.001));
        expect(back.dy, closeTo(src.dy, 0.001));
      }
    });

    test('a point outside the crop maps to null', () {
      final f = CoverFit.cropped(
          const Size(390, 260), const Rect.fromLTWH(120, 60, 400, 300));
      // Well left of the crop, in image coordinates.
      expect(f.toImage(f.toWidget(const Offset(10, 10)), 960, 720), isNull);
    });

    test('contain shows the whole source rect', () {
      const box = Size(400, 400);
      const crop = Rect.fromLTWH(0, 0, 960, 720);
      final f = CoverFit.cropped(box, crop, contain: true);
      final d = f.destination;
      expect(d.width, lessThanOrEqualTo(box.width + 0.001));
      expect(d.height, lessThanOrEqualTo(box.height + 0.001));
      expect(d.width, closeTo(400, 0.001));
    });

    test('the default factory still fits the whole image', () {
      final a = CoverFit(const Size(390, 260), 960, 720);
      final b = CoverFit.cropped(
          const Size(390, 260), const Rect.fromLTWH(0, 0, 960, 720));
      expect(a.scale, closeTo(b.scale, 1e-9));
      expect(a.dx, closeTo(b.dx, 1e-9));
      expect(a.dy, closeTo(b.dy, 1e-9));
    });
  });

  group('ScanAnnotation', () {
    test('survives a JSON round trip', () {
      const a = ScanAnnotation(
        crop: Rect.fromLTWH(10, 20, 300, 200),
        labels: [
          StructureLabel(
              letter: 'A',
              name: 'Soleus',
              kind: StructureKind.muscle,
              point: Offset(100, 50)),
          StructureLabel(
              letter: 'B',
              name: 'Tibial nerve',
              kind: StructureKind.nerve,
              point: Offset(140, 90)),
        ],
      );
      final back = ScanAnnotation.fromJson(a.toJson());
      expect(back.crop, a.crop);
      expect(back.labels.length, 2);
      expect(back.labels[1].name, 'Tibial nerve');
      expect(back.labels[1].kind, StructureKind.nerve);
      expect(back.labels[0].point, const Offset(100, 50));
    });

    test('the full frame is stored as an absent crop, not a full-size one', () {
      const a = ScanAnnotation();
      expect(a.toJson().containsKey('crop'), isFalse);
      expect(ScanAnnotation.fromJson(a.toJson()).crop, isNull);
    });

    test('nextLetter fills the first gap', () {
      const a = ScanAnnotation(labels: [
        StructureLabel(
            letter: 'A', name: 'x', kind: StructureKind.muscle, point: Offset.zero),
        StructureLabel(
            letter: 'C', name: 'y', kind: StructureKind.muscle, point: Offset.zero),
      ]);
      expect(a.nextLetter, 'B');
    });

    test('a malformed label is dropped rather than failing the scan', () {
      final parsed = ScanAnnotation.fromJson({
        'labels': [
          {'letter': 'A', 'name': 'Good', 'kind': 'muscle', 'x': 1, 'y': 2},
          {'letter': 'B', 'name': 'No coordinates', 'kind': 'muscle'},
          {'name': 'No letter', 'kind': 'muscle', 'x': 3, 'y': 4},
        ]
      });
      expect(parsed.labels.map((l) => l.letter), ['A']);
    });

    test('an unknown kind reads as other rather than throwing', () {
      final parsed = ScanAnnotation.fromJson({
        'labels': [
          {'letter': 'A', 'name': 'x', 'kind': 'tendon', 'x': 1, 'y': 2}
        ]
      });
      expect(parsed.labels.single.kind, StructureKind.other);
    });
  });
}

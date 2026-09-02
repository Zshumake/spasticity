import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:neuroinject/data/cover_fit.dart';

/// The painter maps burned-label rectangles source -> widget; the hit test maps
/// a tap widget -> source. If those two ever disagree, the identify round marks
/// correct taps wrong and covers the wrong part of the image. They share
/// [CoverFit] precisely so this can be pinned once.
void main() {
  group('CoverFit', () {
    const iw = 960, ih = 720;

    test('round-trips a point through both directions', () {
      for (final box in [
        const Size(390, 260),
        const Size(402, 700),
        const Size(1024, 300),
        const Size(200, 900),
      ]) {
        final f = CoverFit(box, iw, ih);
        for (final src in [
          const Offset(0, 0),
          const Offset(480, 360),
          const Offset(959, 719),
          const Offset(123, 456),
        ]) {
          final widget = f.toWidget(src);
          final back = f.toImage(widget, iw, ih);
          expect(back, isNotNull, reason: 'box $box src $src');
          expect(back!.dx, closeTo(src.dx, 0.001));
          expect(back.dy, closeTo(src.dy, 0.001));
        }
      }
    });

    test('cover fills the box: the whole widget maps inside the image', () {
      const box = Size(390, 260);
      final f = CoverFit(box, iw, ih);
      for (final corner in [
        const Offset(0.5, 0.5),
        Offset(box.width - 0.5, 0.5),
        Offset(0.5, box.height - 0.5),
        Offset(box.width - 0.5, box.height - 0.5),
      ]) {
        expect(f.toImage(corner, iw, ih), isNotNull, reason: 'corner $corner');
      }
    });

    test('the image centre lands at the widget centre', () {
      const box = Size(390, 260);
      final f = CoverFit(box, iw, ih);
      final c = f.toWidget(const Offset(iw / 2, ih / 2));
      expect(c.dx, closeTo(box.width / 2, 0.001));
      expect(c.dy, closeTo(box.height / 2, 0.001));
    });

    test('a rect keeps its proportions and its mapped origin', () {
      const box = Size(390, 260);
      final f = CoverFit(box, iw, ih);
      const src = Rect.fromLTWH(100, 50, 200, 30);
      final r = f.rectToWidget(src);
      final origin = f.toWidget(const Offset(100, 50));
      expect(r.left, closeTo(origin.dx, 0.001));
      expect(r.top, closeTo(origin.dy, 0.001));
      expect(r.width / r.height, closeTo(src.width / src.height, 0.001));
    });

    test('a point outside the widget maps outside the image', () {
      const box = Size(390, 260);
      final f = CoverFit(box, iw, ih);
      expect(f.toImage(const Offset(-40, 10), iw, ih), isNull);
    });
  });
}

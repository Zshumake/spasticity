import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neuroinject/data/mask_probe.dart';

/// The identify round is only honest if a tap maps onto the mask the same way
/// the painter maps the image onto the screen. Both use a centre-aligned
/// BoxFit.cover, and these pin that agreement down: get it wrong and the app
/// confidently marks correct answers wrong.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MaskProbe against a real bundled mask', () {
    late MaskProbe probe;

    setUpAll(() async {
      final p = await MaskProbe.load(
          'assets/images/us_reference/pec-major-us.mask.png');
      expect(p, isNotNull, reason: 'pec-major mask should be bundled');
      probe = p!;
    });

    test('a missing mask loads as null rather than throwing', () async {
      expect(await MaskProbe.load('assets/images/us_reference/nope.mask.png'),
          isNull);
    });

    test('the mask has real extent and a drawn region', () {
      expect(probe.width, greaterThan(100));
      expect(probe.height, greaterThan(100));
      var drawn = 0;
      for (var y = 0; y < probe.height; y += 8) {
        for (var x = 0; x < probe.width; x += 8) {
          if (probe.alphaAt(x, y) >= 40) drawn++;
        }
      }
      expect(drawn, greaterThan(0), reason: 'mask must mark some muscle');
    });

    test('alpha outside the image bounds is zero, never an exception', () {
      expect(probe.alphaAt(-1, 0), 0);
      expect(probe.alphaAt(0, -1), 0);
      expect(probe.alphaAt(probe.width, 0), 0);
      expect(probe.alphaAt(0, probe.height), 0);
    });

    test('cover mapping puts the widget centre at the image centre', () {
      const box = Size(390, 260);
      final p = probe.toImage(const Offset(195, 130), box);
      expect(p, isNotNull);
      expect(p!.dx, closeTo(probe.width / 2, 1.0));
      expect(p.dy, closeTo(probe.height / 2, 1.0));
    });

    test('cover crops rather than letterboxes: no transparent margin', () {
      // Under cover, every corner of the widget still lands inside the image —
      // that is exactly what distinguishes it from contain, and why a tap can
      // never fall in dead space.
      const box = Size(390, 260);
      for (final corner in [
        const Offset(0.5, 0.5),
        Offset(box.width - 0.5, 0.5),
        Offset(0.5, box.height - 0.5),
        Offset(box.width - 0.5, box.height - 0.5),
      ]) {
        expect(probe.toImage(corner, box), isNotNull,
            reason: 'corner $corner should map inside the image');
      }
    });

    test('a tap on a drawn pixel hits, and one on empty alpha misses', () {
      const box = Size(390, 260);
      // Find any point that maps to a drawn pixel, then assert hit() agrees.
      Offset? onMuscle;
      Offset? offMuscle;
      for (var i = 0; i <= 100 && (onMuscle == null || offMuscle == null); i++) {
        for (var j = 0; j <= 100; j++) {
          final local = Offset(box.width * i / 100, box.height * j / 100);
          final img = probe.toImage(local, box);
          if (img == null) continue;
          final a = probe.alphaAt(img.dx.round(), img.dy.round());
          if (a >= 40) {
            onMuscle ??= local;
          } else if (a == 0) {
            offMuscle ??= local;
          }
        }
      }
      expect(onMuscle, isNotNull);
      expect(offMuscle, isNotNull);
      expect(probe.hit(onMuscle!, box), isTrue);
      expect(probe.hit(offMuscle!, box), isFalse);
    });

    test('the box size changes the mapping, so geometry must match the paint',
        () {
      final wide = probe.toImage(const Offset(100, 100), const Size(600, 200));
      final tall = probe.toImage(const Offset(100, 100), const Size(200, 600));
      expect(wide, isNotNull);
      expect(tall, isNotNull);
      expect(wide!.dx, isNot(closeTo(tall!.dx, 1.0)));
    });
  });
}

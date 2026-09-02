import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neuroinject/widgets/highlight/baked_highlight.dart';

/// The whole point of the highlight is that it colours the muscle WITHOUT
/// flattening its echotexture. That is a claim about compositing, so it is
/// tested on real rendered pixels rather than on widget structure.

const int _w = 64;
const int _h = 32;

/// A fake "scan": vertical stripes of alternating luminance, standing in for
/// the speckle and fascial lines a real ultrasound carries.
Future<ui.Image> _stripedScan() {
  final px = Uint8List(_w * _h * 4);
  for (var y = 0; y < _h; y++) {
    for (var x = 0; x < _w; x++) {
      final v = (x % 4 < 2) ? 40 : 200; // strong local contrast
      final i = (y * _w + x) * 4;
      px[i] = px[i + 1] = px[i + 2] = v;
      px[i + 3] = 255;
    }
  }
  return _decodeRgba(px);
}

/// A fake baked mask: white RGB, alpha 255 on the left half, 0 on the right.
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
  painter.paint(Canvas(rec), Size(_w.toDouble(), _h.toDouble()));
  final img = await rec.endRecording().toImage(_w, _h);
  return (await img.toByteData(format: ui.ImageByteFormat.rawRgba))!;
}

({int r, int g, int b}) _at(ByteData d, int x, int y) {
  final i = (y * _w + x) * 4;
  return (r: d.getUint8(i), g: d.getUint8(i + 1), b: d.getUint8(i + 2));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ui.Image scan;
  late ui.Image mask;

  setUpAll(() async {
    scan = await _stripedScan();
    mask = await _halfMask();
  });

  BakedHighlightPainter painter({double intensity = 1.0}) =>
      BakedHighlightPainter(
        scan: scan,
        mask: mask,
        accent: const Color(0xFF18A98A), // AppTheme.primary
        intensity: intensity,
        fit: BoxFit.fill,
      );

  test('tinted region keeps its texture: dark and bright stripes stay apart',
      () async {
    final d = await _render(painter());
    // x=0 and x=2 are a dark/bright stripe pair inside the masked half.
    final dark = _at(d, 0, 16);
    final bright = _at(d, 2, 16);
    final dl = dark.r + dark.g + dark.b;
    final bl = bright.r + bright.g + bright.b;
    expect(bl - dl, greaterThan(200),
        reason: 'BlendMode.color must preserve luminosity; a flat alpha wash '
            'would collapse these two stripes toward each other');
  });

  test('tinted region actually takes the accent hue', () async {
    final d = await _render(painter());
    final p = _at(d, 2, 16); // bright stripe, masked half
    expect(p.g, greaterThan(p.r),
        reason: 'teal accent should push green above red');
    expect(p.g, greaterThan(p.b),
        reason: 'teal accent should push green above blue');
  });

  test('unmasked region is left exactly as the scan was', () async {
    final d = await _render(painter());
    final dark = _at(d, _w - 4, 16); // right half, alpha 0
    final bright = _at(d, _w - 2, 16);
    expect(dark.r, equals(dark.g));
    expect(dark.g, equals(dark.b), reason: 'must stay neutral grey');
    expect(bright.r, equals(bright.b), reason: 'must stay neutral grey');
  });

  test('intensity 0 leaves the whole scan untouched', () async {
    final d = await _render(painter(intensity: 0));
    final p = _at(d, 2, 16);
    expect(p.r, equals(p.g));
    expect(p.g, equals(p.b));
  });
}

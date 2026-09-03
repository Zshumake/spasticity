import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'cover_fit.dart';

/// Reads a baked highlight mask as data, so a tap can be judged against it.
///
/// The masks were made to be *painted*; this reads the same file as an answer
/// key. That is what makes the identify round nearly free: the app already
/// knows, per pixel, which part of the scan is the muscle, so "did they tap
/// the right structure" needs no new content, no coordinates authored by hand,
/// and no second source of truth to keep in step with the highlights.
class MaskProbe {
  final int width;
  final int height;
  final ByteData _rgba;

  const MaskProbe._(this.width, this.height, this._rgba);

  /// Decodes [asset] into a probe, or null when it is not bundled.
  static Future<MaskProbe?> load(String asset) async {
    try {
      final data = await rootBundle.load(asset);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final image = (await codec.getNextFrame()).image;
      final bytes =
          await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      final w = image.width, h = image.height;
      image.dispose();
      if (bytes == null) return null;
      return MaskProbe._(w, h, bytes);
    } catch (_) {
      return null;
    }
  }

  /// Alpha (0-255) at an image pixel; 0 outside the image.
  int alphaAt(int x, int y) {
    if (x < 0 || y < 0 || x >= width || y >= height) return 0;
    return _rgba.getUint8((y * width + x) * 4 + 3);
  }

  /// Maps a point in a [box]-sized widget onto image pixels for a
  /// centre-aligned [BoxFit.cover] — the fit every scan is painted with.
  /// Returns null when the point falls outside the image.
  Offset? toImage(Offset local, Size box) {
    if (box.width <= 0 || box.height <= 0) return null;
    return CoverFit(box, width, height).toImage(local, width, height);
  }

  /// Whether a tap landed on the muscle.
  ///
  /// [threshold] is deliberately low. The bake feathers the mask to nothing
  /// across the border precisely because the border is uncertain where fascia
  /// is weak, so demanding full opacity would mark a correct tap near the edge
  /// wrong — and being harsh about a boundary the image itself cannot resolve
  /// would teach false precision.
  bool hit(Offset local, Size box, {int threshold = 40}) {
    final p = toImage(local, box);
    if (p == null) return false;
    return alphaAt(p.dx.round(), p.dy.round()) >= threshold;
  }
}

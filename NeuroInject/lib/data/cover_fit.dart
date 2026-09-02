import 'dart:ui';

/// The one place the centre-aligned [BoxFit.cover] transform is written down.
///
/// Two things depend on it and MUST agree: the painter, which maps burned-label
/// rectangles from source pixels onto the widget, and the hit test, which maps
/// a tap the other way to ask the mask whether it landed on the muscle. When
/// those drift, the app confidently marks correct answers wrong — a bug that
/// looks like bad content rather than bad geometry, so it is worth one shared
/// function and a test that pins them as inverses.
class CoverFit {
  final double scale;
  final double dx;
  final double dy;

  const CoverFit._(this.scale, this.dx, this.dy);

  factory CoverFit(Size box, int imageWidth, int imageHeight) {
    final sx = box.width / imageWidth;
    final sy = box.height / imageHeight;
    final s = sx > sy ? sx : sy;
    return CoverFit._(
      s,
      (box.width - imageWidth * s) / 2,
      (box.height - imageHeight * s) / 2,
    );
  }

  /// Source-image point -> widget point.
  Offset toWidget(Offset src) =>
      Offset(dx + src.dx * scale, dy + src.dy * scale);

  /// Source-image rect -> widget rect.
  Rect rectToWidget(Rect src) => Rect.fromLTWH(
      dx + src.left * scale, dy + src.top * scale,
      src.width * scale, src.height * scale);

  /// Widget point -> source-image point. Null when it falls outside the image,
  /// which under cover can only happen for a point outside the widget.
  Offset? toImage(Offset local, int imageWidth, int imageHeight) {
    final x = (local.dx - dx) / scale;
    final y = (local.dy - dy) / scale;
    if (x < 0 || y < 0 || x >= imageWidth || y >= imageHeight) return null;
    return Offset(x, y);
  }
}

import 'dart:ui';

/// The one place the image-to-widget transform is written down.
///
/// Several things depend on it and MUST agree: the painter, which maps
/// burned-label rectangles and structure letters from source pixels onto the
/// widget; the hit test, which maps a tap the other way to ask the mask whether
/// it landed on the muscle; and the annotator, which turns a tap into the
/// source-pixel coordinate it stores. When those drift, the app confidently
/// marks correct answers wrong — a bug that looks like bad content rather than
/// bad geometry, so it is worth one shared function and a test that pins them
/// as inverses.
///
/// CROP LIVES HERE, DELIBERATELY. A presentation crop is expressed as the
/// [source] rectangle this fit maps onto the widget, rather than as a separate
/// step applied to the scan. The scan and its mask are pixel-aligned at
/// identical dimensions, and the invariant that keeps the highlight registered
/// is that they are never scaled or cropped independently. Putting the crop in
/// the transform makes that structural: both images are drawn through this one
/// object, so a crop that moved the scan without moving its mask is not
/// expressible.
class CoverFit {
  final double scale;
  final double dx;
  final double dy;

  /// The region of the source image this fit maps onto the widget. The whole
  /// image unless a crop is in force.
  final Rect source;

  const CoverFit._(this.scale, this.dx, this.dy, this.source);

  /// Fit the whole image, centre-aligned [BoxFit.cover].
  factory CoverFit(Size box, int imageWidth, int imageHeight) => CoverFit.cropped(
      box, Rect.fromLTWH(0, 0, imageWidth.toDouble(), imageHeight.toDouble()));

  /// Fit [source] (a rect in source-image pixels) into [box].
  ///
  /// Cover by default: the source rect fills the box and overflow is clipped by
  /// the caller. With [contain] the whole source rect is visible and the box is
  /// letterboxed — what the annotator uses, because you cannot crop what you
  /// cannot see.
  factory CoverFit.cropped(Size box, Rect source, {bool contain = false}) {
    final sx = box.width / source.width;
    final sy = box.height / source.height;
    final s = contain ? (sx < sy ? sx : sy) : (sx > sy ? sx : sy);
    return CoverFit._(
      s,
      (box.width - source.width * s) / 2 - source.left * s,
      (box.height - source.height * s) / 2 - source.top * s,
      source,
    );
  }

  /// Source-image point -> widget point.
  Offset toWidget(Offset src) =>
      Offset(dx + src.dx * scale, dy + src.dy * scale);

  /// Source-image rect -> widget rect.
  Rect rectToWidget(Rect src) => Rect.fromLTWH(
      dx + src.left * scale, dy + src.top * scale,
      src.width * scale, src.height * scale);

  /// Where [source] lands on the widget — the destination for the image draw.
  Rect get destination => rectToWidget(source);

  /// Widget point -> source-image point. Null when it falls outside the image
  /// or outside the visible [source] region: under cover that means a point
  /// outside the widget, and under a crop or contain it means a point that is
  /// genuinely not showing any image.
  Offset? toImage(Offset local, int imageWidth, int imageHeight) {
    final x = (local.dx - dx) / scale;
    final y = (local.dy - dy) / scale;
    if (x < 0 || y < 0 || x >= imageWidth || y >= imageHeight) return null;
    if (x < source.left ||
        y < source.top ||
        x >= source.right ||
        y >= source.bottom) {
      return null;
    }
    return Offset(x, y);
  }
}

import 'dart:ui';

/// A freehand stroke in canvas-local coordinates (the points the clinician drew).
typedef Stroke = List<Offset>;

/// Input to a [MuscleSegmenter]: the rough drawing over the US image plus the
/// size of the canvas it was drawn on. When a real ML segmenter lands this will
/// also carry the image pixels; the v1 stub ignores them.
class SegmentationInput {
  final List<Stroke> strokes;
  final Size canvasSize;
  const SegmentationInput({required this.strokes, required this.canvasSize});

  /// All stroke points flattened, in draw order.
  List<Offset> get points => [for (final s in strokes) ...s];
}

/// The refined muscle mask: a closed polygon outline in canvas-local coords.
class SegmentationResult {
  final List<Offset> polygon;

  /// 0–1 model confidence. The stub is certain about the user's own drawing.
  final double confidence;

  const SegmentationResult({required this.polygon, this.confidence = 1.0});

  static const SegmentationResult empty =
      SegmentationResult(polygon: <Offset>[]);

  bool get isEmpty => polygon.length < 3;
}

/// The swappable seam: turn a rough drawing into a precise muscle mask.
///
/// v1 ships [PolygonStubSegmenter] (the drawing IS the mask). A MobileSAM /
/// Core ML implementation will replace it WITHOUT touching the drawing surface
/// or the overlay — they only depend on this interface.
abstract class MuscleSegmenter {
  Future<SegmentationResult> refine(SegmentationInput input);
}

/// v1 stub: treats the drawn lasso itself as the mask (identity "refinement").
///
/// It flattens the strokes into one closed outline and lightly decimates the
/// points so the polygon is not absurdly dense. Good enough to build and demo
/// the whole draw → highlight loop; a real model will tighten this to the
/// fascial border and ignore a sloppy gesture.
class PolygonStubSegmenter implements MuscleSegmenter {
  /// Minimum gap (canvas px) between kept points — cheap stand-in for the
  /// Douglas–Peucker simplification a real pipeline would use.
  final double minGap;

  const PolygonStubSegmenter({this.minGap = 4.0});

  @override
  Future<SegmentationResult> refine(SegmentationInput input) async {
    final pts = input.points;
    if (pts.length < 3) return SegmentationResult.empty;

    final kept = <Offset>[pts.first];
    for (final p in pts.skip(1)) {
      if ((p - kept.last).distance >= minGap) kept.add(p);
    }
    if (kept.length < 3) return SegmentationResult.empty;
    return SegmentationResult(polygon: kept);
  }
}

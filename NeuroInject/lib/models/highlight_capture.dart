import 'dart:ui';

/// One accepted muscle highlight — the unit of training data the feature
/// generates through normal use: which muscle, which US image, and the
/// clinician-confirmed mask outline. As captures accumulate they become the
/// dataset that adapts the segmenter to ultrasound (the v1.5 LoRA pass).
///
/// [imageRef] is a bundled asset path today (`<id>-us.jpg`); when the app
/// captures live US frames it becomes a stored file path. The polygon is in
/// canvas-local coordinates, with [canvasSize] so it can be normalised later.
class HighlightCapture {
  final String id;
  final String muscleId;
  final String imageRef;
  final List<Offset> polygon;
  final Size canvasSize;
  final int createdAtMillis;

  const HighlightCapture({
    required this.id,
    required this.muscleId,
    required this.imageRef,
    required this.polygon,
    required this.canvasSize,
    required this.createdAtMillis,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'muscleId': muscleId,
        'imageRef': imageRef,
        'polygon': [
          for (final o in polygon) [o.dx, o.dy]
        ],
        'canvasW': canvasSize.width,
        'canvasH': canvasSize.height,
        'createdAt': createdAtMillis,
      };

  factory HighlightCapture.fromJson(Map<String, dynamic> j) => HighlightCapture(
        id: j['id'] as String,
        muscleId: j['muscleId'] as String,
        imageRef: j['imageRef'] as String,
        polygon: [
          for (final p in (j['polygon'] as List))
            Offset((p[0] as num).toDouble(), (p[1] as num).toDouble())
        ],
        canvasSize: Size(
            (j['canvasW'] as num).toDouble(), (j['canvasH'] as num).toDouble()),
        createdAtMillis: j['createdAt'] as int,
      );
}

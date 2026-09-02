import 'package:flutter/material.dart';
import '../../models/segmentation.dart';

/// Renders the live drawing stroke and the committed muscle mask: a soft glow,
/// a tinted fill, and a crisp anti-aliased outline in the accent colour.
///
/// The glow uses a blurred stroke (cheap, no shader). A fragment-shader glow is
/// a v1.5 polish; the contour smoothing (marching-squares + Douglas–Peucker)
/// will live in the segmenter once a real mask model produces a bitmap.
class MuscleOverlayPainter extends CustomPainter {
  final List<Offset> liveStroke;
  final SegmentationResult? mask;
  final Color accent;

  /// [repaint] drives live-stroke repaints without rebuilding any widget: the
  /// canvas mutates [liveStroke] in place and ticks this listenable, so only the
  /// painter (inside a RepaintBoundary) repaints during a drag — not the screen.
  MuscleOverlayPainter({
    required this.liveStroke,
    required this.mask,
    required this.accent,
    super.repaint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final m = mask;
    if (m != null && m.polygon.length >= 3) {
      final path = Path()..addPolygon(m.polygon, true);

      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..color = accent.withAlpha(120)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.fill
          ..color = accent.withAlpha(46),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeJoin = StrokeJoin.round
          ..color = accent
          ..isAntiAlias = true,
      );
    }

    if (liveStroke.length >= 2) {
      final p = Path()..moveTo(liveStroke.first.dx, liveStroke.first.dy);
      for (final o in liveStroke.skip(1)) {
        p.lineTo(o.dx, o.dy);
      }
      canvas.drawPath(
        p,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = accent.withAlpha(210)
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..isAntiAlias = true,
      );
    }
  }

  @override
  bool shouldRepaint(MuscleOverlayPainter old) =>
      old.mask != mask || old.accent != accent;
}

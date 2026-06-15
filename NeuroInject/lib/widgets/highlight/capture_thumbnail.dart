import 'package:flutter/material.dart';
import '../../models/highlight_capture.dart';
import '../../theme/app_theme.dart';

/// Small preview of one [HighlightCapture]: the US image with the stored mask
/// polygon scaled from its original canvas onto this thumbnail.
class CaptureThumbnail extends StatelessWidget {
  final HighlightCapture capture;
  final Color accent;

  const CaptureThumbnail(
      {super.key, required this.capture, required this.accent});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        child: Stack(fit: StackFit.expand, children: [
          Image.asset(capture.imageRef, fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(color: AppTheme.bgDark)),
          Positioned.fill(
            child: CustomPaint(painter: _MaskThumbPainter(capture, accent)),
          ),
        ]),
      ),
    );
  }
}

class _MaskThumbPainter extends CustomPainter {
  final HighlightCapture capture;
  final Color accent;
  _MaskThumbPainter(this.capture, this.accent);

  @override
  void paint(Canvas canvas, Size size) {
    final cs = capture.canvasSize;
    if (cs.width <= 0 || cs.height <= 0 || capture.polygon.length < 3) return;
    final sx = size.width / cs.width;
    final sy = size.height / cs.height;
    final pts = [for (final o in capture.polygon) Offset(o.dx * sx, o.dy * sy)];
    final path = Path()..addPolygon(pts, true);
    canvas.drawPath(
        path, Paint()..color = accent.withAlpha(54));
    canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeJoin = StrokeJoin.round
          ..color = accent
          ..isAntiAlias = true);
  }

  @override
  bool shouldRepaint(_MaskThumbPainter old) =>
      old.capture != capture || old.accent != accent;
}
